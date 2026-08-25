// lib/config/production.dart
//
// Production-only configuration constants — Vendor App.
// Values baked into release APK/AAB at build time.
//
// ⚠️  Update apiBaseUrl to match your production server domain before releasing.

class ProductionConfig {
  ProductionConfig._();

  /// Production API base URL.
  /// ⚠️  Update this before releasing to Google Play.
  static const String apiBaseUrl = 'https://alanga-app.vercel.app/api/v1';

  /// Disable verbose API logging in production.
  static const bool enableApiLogging = false;

  /// Disable debug tools in production.
  static const bool enableDebugTools = false;

  /// Environment label for display purposes.
  static const String environmentLabel = 'PROD';
}
