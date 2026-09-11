import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

enum AppEnvironment { development, production }

class EnvironmentConfig {
  /// Production API base URL.
  /// ⚠️  Update this before releasing to Google Play.
  static const String _prodUrl = 'https://alanga-app.vercel.app/api/v1';

  static String _getDevUrl() {
    // Override at build time for physical device testing:
    // flutter run --dart-define=LOCAL_IP=192.168.x.x
    const localIp = String.fromEnvironment('LOCAL_IP');
    if (localIp.isNotEmpty) {
      return 'http://$localIp:3000/api/v1';
    }

    // Default development server IP for physical devices & local testing
    return 'http://192.168.29.154:3000/api/v1';
  }

  /// Current environment based on Flutter build mode.
  static AppEnvironment get environment {
    if (kReleaseMode) return AppEnvironment.production;
    return AppEnvironment.development;
  }

  /// Whether the app is running in production (release) mode.
  static bool get isProduction => environment == AppEnvironment.production;

  /// Whether debug logging is enabled.
  /// Always false in production to avoid leaking data in logs.
  static bool get isDebugLoggingEnabled => !isProduction;

  /// The base API URL for the current environment.
  /// Can be overridden at build time:
  ///   --dart-define=ENV=prod   → always use production URL
  ///   --dart-define=ENV=dev    → always use development URL
  static String get baseUrl {
    const envDefine = String.fromEnvironment('ENV');
    if (envDefine == 'prod') return _prodUrl;
    if (envDefine == 'dev') return _getDevUrl();

    // Automatic fallback: release → production, debug/profile → development
    switch (environment) {
      case AppEnvironment.production:
        return _prodUrl;
      case AppEnvironment.development:
        return _getDevUrl();
    }
  }
}
