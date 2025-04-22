// colorful print
import 'dart:developer';

import 'package:gunwave/data/constants/app_constant.dart';

///Black:   \x1B[30m
// Red:     \x1B[31m
// Green:   \x1B[32m
// Yellow:  \x1B[33m
// Blue:    \x1B[34m
// Magenta: \x1B[35m
// Cyan:    \x1B[36m
// White:   \x1B[37m
// Reset:   \x1B[0m

void logSafe(dynamic msg, {Object? e, StackTrace? stack}){
  log('\x1B[32m=====${[AppConstant.appName]}=====$msg\x1B[0m', error: e, stackTrace: stack, level: 1000);
}

void logWarning(dynamic msg, {Object? e, StackTrace? stack}){
  log('\x1B[33m=====${[AppConstant.appName]}=====$msg\x1B[0m', error: e, stackTrace: stack, level: 1000);
}

void logError(dynamic runtimeType, {Object? e, StackTrace? stack}){
  log('\x1B[31m=====${[AppConstant.appName]}=====>🐞🐞🐞INTERNAL ERROR ON $runtimeType\x1B[0m', error: e, stackTrace: stack, level: 1000);
}
