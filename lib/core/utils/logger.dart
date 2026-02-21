import 'package:logger/logger.dart';

/// App-wide structured logger.
/// Usage: `Log.i('message')`, `Log.e('error', error: e, stackTrace: s)`
abstract class Log {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
    // In release builds, restrict to warnings and above.
    level: const bool.fromEnvironment('dart.vm.product')
        ? Level.warning
        : Level.trace,
  );

  static void t(String message) => _logger.t(message);
  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);
  static void e(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  static void f(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
