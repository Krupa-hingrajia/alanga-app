// lib/config/production.dart
//
// Production-only configuration constants.
// These values are baked into the release APK/AAB when built with:
//   flutter build apk --release --dart-define=ENV=prod
//   flutter build appbundle --release --dart-define=ENV=prod
//
// ⚠️  Update apiBaseUrl to match your production server domain before releasing.

class ProductionConfig {
  ProductionConfig._();

  /// Production API base URL.
  /// Update this to your production server URL before releasing to Google Play.
  static const String apiBaseUrl = 'https://alanga-app.vercel.app/api/v1';

  /// Disable verbose API logging in production.
  static const bool enableApiLogging = false;

  /// Disable debug tools in production.
  static const bool enableDebugTools = false;

  /// Environment label for display purposes.
  static const String environmentLabel = 'PROD';
}
