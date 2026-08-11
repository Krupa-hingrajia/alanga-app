import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

enum AppEnvironment { development, production }

class EnvironmentConfig {
  static final String _devUrl = _getDevUrl();
  static const String _prodUrl = 'https://alanga-app.vercel.app/api/v1';

  static String _getDevUrl() {
    // Allows testing on physical devices by passing the laptop's local IP address:
    // flutter run --dart-define=LOCAL_IP=192.168.1.XX
    const localIp = String.fromEnvironment('LOCAL_IP');
    if (localIp.isNotEmpty) {
      return 'http://$localIp:3000/api/v1';
    }

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }

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
