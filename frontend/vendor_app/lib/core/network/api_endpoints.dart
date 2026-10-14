import '../config/environment_config.dart';

class ApiEndpoints {
  static String get baseUrl => EnvironmentConfig.baseUrl;

  // Auth endpoints
  static const String checkAvailability = '/auth/check-availability';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String phoneAuth = '/auth/phone-auth';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String deleteAccount = '/auth/delete-account';
  static const String updateProfile = '/auth/profile';

  // Vendor Dashboard & Profile endpoints
  static const String vendorDashboardSummary = '/vendor/dashboard/summary';
  static const String vendorProfile = '/vendor/profile';

  // Notifications endpoints
  static const String fcmToken = '/notifications/fcm-token';
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';
}
