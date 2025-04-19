import 'package:flutter/foundation.dart';
import 'package:gunwave/utils/exception/ignore_exception.dart';
import 'package:gunwave/utils/logger/app_logger.dart';

class AppException implements Exception {
  int code;
  String message;

  AppException({this.code = 1, required this.message});

  static log(dynamic runtimeType, Object e, StackTrace stack) {
    if (kDebugMode) logError(runtimeType, e: e, stack: stack);
    switch (e.runtimeType) {
      case const (IgnoreException):
        break;
      default:
        // Sentry.captureException(e, stackTrace: stack);
        break;
    }
  }
}
