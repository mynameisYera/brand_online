import 'dart:io';
import 'package:flutter/services.dart';

class ScreenSecure {
  static const _ch = MethodChannel('screen_security');

  static Future<void> enable() async {
    if (Platform.isAndroid) {
      try { await _ch.invokeMethod('enableSecure'); } catch (_) {}
    }
  }

  static Future<void> disable() async {
    if (Platform.isAndroid) {
      try { await _ch.invokeMethod('disableSecure'); } catch (_) {}
    }
  }
}
