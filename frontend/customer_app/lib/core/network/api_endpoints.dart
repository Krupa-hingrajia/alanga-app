import '../config/environment_config.dart';

class ApiEndpoints {
  static String get baseUrl => EnvironmentConfig.baseUrl;

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String sendPhoneOtp = '/auth/send-phone-otp';
  static const String verifyPhoneOtp = '/auth/verify-phone-otp';
}
