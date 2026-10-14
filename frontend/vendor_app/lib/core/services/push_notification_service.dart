import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../dependency_injection/injection.dart';
import '../network/api_endpoints.dart';
import '../network/api_service.dart';
import '../storage/secure_storage_service.dart';
import '../../routes/app_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('FCM background message received: ${message.messageId} | ${message.data}');
}

const AndroidNotificationChannel _vendorNotificationChannel = AndroidNotificationChannel(
  'alanga_vendor_notifications',
  'Alanga Vendor Notifications',
  description: 'High priority notifications for new orders, KYC updates, and product approvals.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Request user permissions (especially for Android 13+ and iOS)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM notification permission status: ${settings.authorizationStatus}');

      // 3. Setup Android notification channel
      if (!kIsWeb && Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_vendorNotificationChannel);
      }

      // 4. Initialize Local Notifications for heads-up foreground presentation
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _localNotifications.initialize(
        const InitializationSettings(android: androidSettings, iOS: darwinSettings),
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!);
              if (data is Map<String, dynamic>) {
                handleNotificationTap(data);
              }
            } catch (e) {
              debugPrint('Error parsing notification payload: $e');
            }
          }
        },
      );

      // 5. Configure Foreground presentation options
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Listen for Foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message: ${message.notification?.title} | ${message.notification?.body}');
        _showForegroundNotification(message);
      });

      // 7. Handle notification tap when app is in Background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Message opened from background: ${message.data}');
        handleNotificationTap(message.data);
      });

      // 8. Handle notification tap when app was completely Terminated / Killed
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('FCM App launched from terminated state via notification: ${initialMessage.data}');
        Future.delayed(const Duration(milliseconds: 1000), () {
          handleNotificationTap(initialMessage.data);
        });
      }

      // 9. Listen for token refresh events
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        syncTokenWithBackend(token: newToken);
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing PushNotificationService: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Alanga Vendor Alert';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _vendorNotificationChannel.id,
          _vendorNotificationChannel.name,
          channelDescription: _vendorNotificationChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void handleNotificationTap(Map<String, dynamic> data) {
    try {
      final type = data['type']?.toString().toUpperCase();
      final orderId = data['orderId']?.toString();
      final productId = data['productId']?.toString();

      debugPrint('Navigating for notification type: $type, orderId: $orderId, productId: $productId');

      if (type == 'ORDER' || type == 'ORDER_STATUS') {
        if (orderId != null && orderId.isNotEmpty) {
          AppRouter.router.push('/orders/$orderId');
        } else {
          AppRouter.router.go('/orders');
        }
      } else if (type == 'PRODUCT_APPROVAL' || type == 'PRODUCT_REJECTION') {
        AppRouter.router.go('/products');
      } else if (type == 'KYC_VERIFIED' || type == 'KYC_REJECTED') {
        AppRouter.router.push('/store-kyc');
      } else {
        // Default: Open Dashboard Alerts tab
        AppRouter.router.go('/dashboard');
      }
    } catch (e) {
      debugPrint('Error navigating on notification tap: $e');
    }
  }

  Future<void> syncTokenWithBackend({String? token}) async {
    try {
      final storage = sl<SecureStorageService>();
      final authToken = await storage.getAccessToken();

      // Only sync if user is logged in
      if (authToken == null || authToken.isEmpty) {
        return;
      }

      final fcmToken = token ?? await _fcm.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      debugPrint('Syncing FCM token to backend: $fcmToken');

      final apiService = sl<ApiService>();
      await apiService.post(
        ApiEndpoints.fcmToken,
        data: {
          'token': fcmToken,
          'deviceType': Platform.isIOS ? 'IOS' : 'ANDROID',
        },
      );
      debugPrint('FCM token successfully registered on backend');
    } catch (e) {
      debugPrint('Failed to sync FCM token with backend: $e');
    }
  }

  Future<void> removeTokenFromBackend() async {
    try {
      final fcmToken = await _fcm.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      final apiService = sl<ApiService>();
      await apiService.delete(
        ApiEndpoints.fcmToken,
        data: {'token': fcmToken},
      );
      debugPrint('FCM token removed from backend on logout');
    } catch (e) {
      debugPrint('Error removing FCM token from backend: $e');
    }
  }
}
