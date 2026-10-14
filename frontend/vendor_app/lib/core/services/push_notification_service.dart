import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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

      // 2. Request user permissions (Firebase & Android 13+)
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

      // 3. Setup Android notification channel & request Android 13+ runtime permission
      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        await androidPlugin?.createNotificationChannel(_vendorNotificationChannel);

        try {
          final granted = await androidPlugin?.requestNotificationsPermission();
          debugPrint('Android Local Notifications permission granted: $granted');
        } catch (e) {
          debugPrint('Error requesting Android local notification permission: $e');
        }
      }

      // 4. Initialize Local Notifications for heads-up foreground presentation
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _localNotifications.initialize(
        settings: const InitializationSettings(android: androidSettings, iOS: darwinSettings),
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
        debugPrint('FCM Foreground message received: title=${message.notification?.title} | body=${message.notification?.body} | data=${message.data}');
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

      // 10. Automatically sync token if already logged in
      syncTokenWithBackend();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing PushNotificationService: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    // 1. Show System Tray / Heads-Up notification
    try {
      final title = message.notification?.title ?? message.data['title'] ?? 'Alanga Vendor Alert';
      final body = message.notification?.body ?? message.data['body'] ?? '';

      _localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _vendorNotificationChannel.id,
            _vendorNotificationChannel.name,
            channelDescription: _vendorNotificationChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            ticker: 'Alanga Vendor',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }

    // 2. Show In-App Floating Banner Alert for instant visibility while app is open
    _showInAppBanner(message);
  }

  void _showInAppBanner(RemoteMessage message) {
    try {
      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context == null) {
        debugPrint('AppRouter root context is null, skipping in-app banner');
        return;
      }

      final title = message.notification?.title ?? message.data['title'] ?? 'Alanga Vendor Alert';
      final body = message.notification?.body ?? message.data['body'] ?? '';
      final type = message.data['type']?.toString().toUpperCase() ?? '';

      IconData iconData = Icons.notifications_active_rounded;
      Color iconColor = const Color(0xFF229944);

      if (type.contains('APPROVAL') || type.contains('VERIFIED')) {
        iconData = Icons.check_circle_rounded;
        iconColor = const Color(0xFF229944);
      } else if (type.contains('REJECT')) {
        iconData = Icons.error_outline_rounded;
        iconColor = const Color(0xFFE6222B);
      } else if (type.contains('ORDER')) {
        iconData = Icons.shopping_bag_rounded;
        iconColor = const Color(0xFFF99F1B);
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF11261B),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF234433), width: 1.2),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            duration: const Duration(seconds: 7),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: const TextStyle(
                            color: Color(0xFFD1DDD6),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: const Color(0xFFF99F1B),
              onPressed: () {
                handleNotificationTap(message.data);
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error presenting in-app banner: $e');
    }
  }

  void handleNotificationTap(Map<String, dynamic> data) {
    try {
      final type = data['type']?.toString().toUpperCase();
      final orderId = data['orderId']?.toString();
      final productId = data['productId']?.toString();

      debugPrint('Navigating for notification type: $type, orderId: $orderId, productId: $productId');

      if (type == 'ORDER' || type == 'ORDER_STATUS') {
        AppRouter.router.push('/orders');
      } else if (type == 'PRODUCT_APPROVAL' || type == 'PRODUCT_REJECTION') {
        AppRouter.router.push('/products');
      } else if (type == 'KYC_VERIFIED' || type == 'KYC_REJECTED') {
        AppRouter.router.push('/kyc');
      } else {
        AppRouter.router.push('/home');
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
