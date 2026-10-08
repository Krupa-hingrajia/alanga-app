import 'package:flutter/foundation.dart';

enum AppEnvironment { development, uat, production }

class EnvironmentConfig {
  /// Production API base URL (Google Cloud Run Singapore - Live Customers).
  static const String _prodUrl = 'https://alanga-backend-807103326316.asia-southeast1.run.app/api/v1';

  /// UAT Testing API base URL (Google Cloud Run Singapore - QA / Staging).
  static const String _uatUrl = 'https://alanga-backend-uat-807103326316.asia-southeast1.run.app/api/v1';

  static String _getDevUrl() {
    const localIp = String.fromEnvironment('LOCAL_IP');
    if (localIp.isNotEmpty) {
      return 'http://$localIp:3000/api/v1';
    }
    // Default fallback to UAT for development builds
    return _uatUrl;
  }

  /// Current environment based on Flutter build mode or ENV flag.
  static AppEnvironment get environment {
    const envDefine = String.fromEnvironment('ENV');
    if (envDefine == 'uat') return AppEnvironment.uat;
    if (envDefine == 'prod' || kReleaseMode) return AppEnvironment.production;
    return AppEnvironment.development;
  }

  /// Whether the app is running in production (release) mode.
  static bool get isProduction => environment == AppEnvironment.production;

  /// Whether debug logging is enabled.
  static bool get isDebugLoggingEnabled => !isProduction;

  /// The base API URL for the current environment.
  /// Can be overridden at build time:
  ///   --dart-define=ENV=prod   → always use production URL
  ///   --dart-define=ENV=uat    → always use UAT URL
  ///   --dart-define=ENV=dev    → always use development URL
  static String get baseUrl {
    const envDefine = String.fromEnvironment('ENV');
    if (envDefine == 'prod') return _prodUrl;
    if (envDefine == 'uat') return _uatUrl;
    if (envDefine == 'dev') return _getDevUrl();

    switch (environment) {
      case AppEnvironment.production:
        return _prodUrl;
      case AppEnvironment.uat:
        return _uatUrl;
      case AppEnvironment.development:
        return _getDevUrl();
    }
  }
}
