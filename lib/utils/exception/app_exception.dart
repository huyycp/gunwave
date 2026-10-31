import 'package:flutter/foundation.dart';
import 'package:gunwave/utils/exception/ignore_exception.dart';
import 'package:gunwave/utils/logger/app_logger.dart';

class AppException implements Exception {
  int code;
  String message;

  AppException({this.code = 1, required this.message});

  /// Logs a debug failure with the class and function that handled it.
  static void log(Type source, Object e, StackTrace stack,
      {required String function}) {
    if (kDebugMode) {
      AppLogger(source)
          .error(function, e.toString(), error: e, stackTrace: stack);
    }
    switch (e.runtimeType) {
      case const (IgnoreException):
        break;
      default:
        // Sentry.captureException(e, stackTrace: stack);
        break;
    }
  }
}
