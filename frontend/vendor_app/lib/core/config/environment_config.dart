import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

enum AppEnvironment { development, production }

class EnvironmentConfig {
  static final String _devUrl = (!kIsWeb && Platform.isAndroid)
      ? 'http://10.0.2.2:3000/api/v1'
      : 'http://localhost:3000/api/v1';
  static const String _prodUrl = 'https://alanga-app.vercel.app/api/v1';

  static AppEnvironment get environment {
    if (kReleaseMode) {
      return AppEnvironment.production;
    }
    return AppEnvironment.development;
  }

  static String get baseUrl {
    // Allows overriding the environment via compile-time variables: --dart-define=ENV=prod or --dart-define=ENV=dev
    const envDefine = String.fromEnvironment('ENV');
    if (envDefine == 'prod') {
      return _prodUrl;
    } else if (envDefine == 'dev') {
      return _devUrl;
    }

    // Fallback automatically to development in debug mode, and production in release mode
    switch (environment) {
      case AppEnvironment.production:
        return _prodUrl;
      case AppEnvironment.development:
        return _devUrl;
    }
  }
}
