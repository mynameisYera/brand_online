import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../service/injectable/injectable_service.dart';

class L {
  static void info(String title, String message) {
    SimpleLogger.info(title, message);
  }

  static void error(String title, String message) {
    SimpleLogger.error(title, message);
  }

  static void log(String title, String message) {
    SimpleLogger.log(title, message);
  }

  static void i(String message) {
    SimpleLogger.info('INFO', message);
  }

  static void e(String message) {
    SimpleLogger.error('ERROR', message);
  }

  static void l(String message) {
    SimpleLogger.log('LOG', message);
  }
  
  static void json(String title, Map<String, dynamic> data) {
    SimpleLogger.json(title, data);
  }
  
  static void jsonPretty(String title, Map<String, dynamic> data) {
    if (kDebugMode) {
      print('📄 [$title] JSON:');
      print(JsonEncoder.withIndent('  ').convert(data));
    }
  }
  
  static void success(String title, String message) {
    SimpleLogger.success(title, message);
  }
  
  static void warning(String title, String message) {
    SimpleLogger.warning(title, message);
  }
  
  static void debug(String message) {
    SimpleLogger.debug(message);
  }
  
}
