// lib/config/environment.dart
//
// Central entry point for environment configuration.
// Import this file wherever you need environment-aware values.
//
// Usage:
//   import 'package:customer_app/config/environment.dart';
//   final url = AppEnvironment.baseUrl;
//   final isProd = AppEnvironment.isProduction;

import 'package:flutter/foundation.dart';
import 'development.dart';
import 'production.dart';

export 'development.dart';
export 'production.dart';

/// Top-level environment accessor.
/// Delegates to [ProductionConfig] in release mode and [DevelopmentConfig] in debug/profile.
class AppEnvironment {
  AppEnvironment._();

  /// Whether the app is running in production (release) mode.
  static bool get isProduction => kReleaseMode;

  /// The base API URL for the current environment.
  /// Can be overridden at build time with `--dart-define=ENV=prod` or `--dart-define=ENV=dev`.
  static String get baseUrl {
    const envDefine = String.fromEnvironment('ENV');
    if (envDefine == 'prod') return ProductionConfig.apiBaseUrl;
    if (envDefine == 'dev') return DevelopmentConfig.apiBaseUrl;
    return isProduction ? ProductionConfig.apiBaseUrl : DevelopmentConfig.apiBaseUrl;
  }

  /// Whether debug logging is enabled (only in non-production builds).
  static bool get isDebugLoggingEnabled => !isProduction;
}
