import 'package:flutter/foundation.dart';

class Colors {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
  static const String brightMagenta = '\x1B[95m';
  static const String brightCyan = '\x1B[96m';
}

class SimpleLogger {
  static void log(String title, String message) {
    if (kDebugMode) {
      print('${Colors.blue}[$title]${Colors.reset} $message');
    }
  }
  
  static void info(String title, String message) {
    print('${Colors.brightGreen}ℹ️ [$title]${Colors.reset} $message');
  }
  
  static void error(String title, String message) {
    print('${Colors.brightRed}❌ [$title]${Colors.reset} $message');
  }
  
  static void debug(String message) {
    if (kDebugMode) {
      print('${Colors.brightYellow}🐛 [DEBUG]${Colors.reset} $message');
    }
  }
  
  static void json(String title, Map<String, dynamic> data) {
    if (kDebugMode) {
      print('${Colors.brightCyan}📄 [$title]${Colors.reset} JSON:');
      print('${Colors.cyan}${data.toString()}${Colors.reset}');
    }
  }
  
  static void success(String title, String message) {
    print('${Colors.brightGreen}✅ [$title]${Colors.reset} $message');
  }
  
  static void warning(String title, String message) {
    print('${Colors.brightYellow}⚠️ [$title]${Colors.reset} $message');
  }
}

class InjectableService {
  static SimpleLogger get getIt => SimpleLogger();
} 