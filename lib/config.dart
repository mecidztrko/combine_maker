import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    // Web
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    // Android Emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    // iOS Simulator / macOS / Others
    return 'http://localhost:3000';
  }
}

