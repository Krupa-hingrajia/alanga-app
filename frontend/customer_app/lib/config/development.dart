// lib/config/development.dart
//
// Development-only configuration constants.
// These values are used when the app is running in debug/profile mode
// or when `--dart-define=ENV=dev` is passed at build time.

class DevelopmentConfig {
  DevelopmentConfig._();

  /// Development API base URL.
  /// Override the IP at build time: flutter run --dart-define=LOCAL_IP=192.168.x.x
  static String get apiBaseUrl {
    const localIp = String.fromEnvironment('LOCAL_IP');
    if (localIp.isNotEmpty) {
      return 'http://$localIp:3000/api/v1';
    }
    // Default to Google Cloud Run Production backend server
    return 'https://alanga-backend-807103326316.asia-southeast1.run.app/api/v1';
  }

  /// Enable verbose API request/response logging in development.
  static const bool enableApiLogging = true;

  /// Enable debug overlay banners and tools.
  static const bool enableDebugTools = true;

  /// Environment label for display purposes.
  static const String environmentLabel = 'DEV';
}
