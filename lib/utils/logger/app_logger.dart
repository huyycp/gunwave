import 'dart:developer' as developer;

/// Writes diagnostics as `[LEVEL][ClassName][FunctionName] message`.
///
/// Create a logger with `AppLogger(runtimeType)` and pass the function name
/// explicitly, so logging does not capture or parse a stack trace on every call.
/// For example: `logger.info('signInAsGuest', 'Guest session ready.');`.
class AppLogger {
  /// Creates a logger scoped to [className].
  const AppLogger(this.className);

  /// The type that owns the operation being logged.
  final Type className;

  /// Records an informational [message] from [function].
  void info(String function, String message) {
    _write('INFO', 800, function, message);
  }

  /// Records a warning [message] from [function].
  void warning(String function, String message) {
    _write('WARNING', 900, function, message);
  }

  /// Records a failure and optionally attaches its exception and stack trace.
  void error(
    String function,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _write('ERROR', 1000, function, message,
        error: error, stackTrace: stackTrace);
  }

  void _write(
    String level,
    int severity,
    String function,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '[$level][$className][$function] $message',
      level: severity,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
