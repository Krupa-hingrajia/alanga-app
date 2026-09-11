// lib/config/development.dart
//
// Development-only configuration constants — Vendor App.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class DevelopmentConfig {
  DevelopmentConfig._();

  /// Development API base URL.
  /// Override at build time: flutter run --dart-define=LOCAL_IP=192.168.x.x
  static String get apiBaseUrl {
    const localIp = String.fromEnvironment('LOCAL_IP');
    if (localIp.isNotEmpty) {
      return 'http://$localIp:3000/api/v1';
    }

    // Android emulator accesses host machine via 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    }

    // Default development server IP
    return 'http://192.168.29.154:3000/api/v1';
  }

  /// Enable verbose API request/response logging in development.
  static const bool enableApiLogging = true;

  /// Enable debug overlay banners and tools.
  static const bool enableDebugTools = true;

  /// Environment label for display purposes.
  static const String environmentLabel = 'DEV';
}
