import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum LogLevel { trace, debug, info, log, warning, error, fatal }

enum LogSource {
  ui,
  service,
  process,
  network,
  storage,
  security,
  system,
}

/// Application logger with logcat-style structured records.
///
/// Features:
/// - Session-scoped log file in `.logs/`
/// - Level/source/component tagging
/// - Release-build hard disable by default
/// - Runtime toggle via `--dart-define=BLINK_ENABLE_LOGS=false`
abstract class Log {
  static const bool _buildAllowsLogs = !kReleaseMode;
  static const bool _runtimeEnabled =
      bool.fromEnvironment('BLINK_ENABLE_LOGS', defaultValue: true);
  static const String _minLevelEnv =
      String.fromEnvironment('BLINK_LOG_LEVEL', defaultValue: 'INFO');

  static bool get _enabled => _buildAllowsLogs && _runtimeEnabled;

  static final LogLevel _minimumLevel = _parseMinLevel(_minLevelEnv);

  static IOSink? _fileSink;
  static bool _initialised = false;
  static String? _currentLogPath;
  static final List<String> _bufferBeforeInit = <String>[];
  static String? _lastLine;
  static LogLevel? _lastLevel;
  static LogSource? _lastSource;
  static int _lastRepeatCount = 0;
  static DateTime? _lastAt;
  static const Duration _dedupeWindow = Duration(milliseconds: 600);

  static String? get currentLogPath => _currentLogPath;

  static Future<void> init() async {
    if (_initialised || !_enabled) {
      _initialised = true;
      return;
    }

    final baseDir = await getApplicationSupportDirectory();
    final logsDir = Directory(p.join(baseDir.path, '.logs'));
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    final fileName = '${_platformName()}-${_timestampForFile(DateTime.now())}.log';
    final file = File(p.join(logsDir.path, fileName));
    _fileSink = file.openWrite(mode: FileMode.append);
    _currentLogPath = file.path;

    _writeRaw('--- Blink session started @ ${DateTime.now().toIso8601String()} ---');
    _writeRaw('--- buildMode=${kReleaseMode ? 'release' : 'dev/test'} ---');
    _writeRaw('--- logs=$fileName ---');

    for (final pending in _bufferBeforeInit) {
      _writeRaw(pending);
    }
    _bufferBeforeInit.clear();
    _initialised = true;
  }

  static Future<void> close() async {
    if (_fileSink != null) {
      _flushRepeats();
      _writeRaw('--- Blink session ended @ ${DateTime.now().toIso8601String()} ---');
      await _fileSink!.flush();
      await _fileSink!.close();
      _fileSink = null;
    }
  }

  static void t(
    String message, {
    LogSource source = LogSource.system,
    String? component,
  }) =>
      _emit(LogLevel.trace, message, source: source, component: component);

  static void d(
    String message, {
    LogSource source = LogSource.system,
    String? component,
  }) =>
      _emit(LogLevel.debug, message, source: source, component: component);

  static void i(
    String message, {
    LogSource source = LogSource.system,
    String? component,
  }) =>
      _emit(LogLevel.info, message, source: source, component: component);

  static void l(
    String message, {
    LogSource source = LogSource.system,
    String? component,
  }) =>
      _emit(LogLevel.log, message, source: source, component: component);

  static void w(
    String message, {
    LogSource source = LogSource.system,
    String? component,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _emit(
        LogLevel.warning,
        message,
        source: source,
        component: component,
        error: error,
        stackTrace: stackTrace,
      );

  static void e(
    String message, {
    LogSource source = LogSource.system,
    String? component,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _emit(
        LogLevel.error,
        message,
        source: source,
        component: component,
        error: error,
        stackTrace: stackTrace,
      );

  static void f(
    String message, {
    LogSource source = LogSource.system,
    String? component,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _emit(
        LogLevel.fatal,
        message,
        source: source,
        component: component,
        error: error,
        stackTrace: stackTrace,
      );

  static void _emit(
    LogLevel level,
    String message, {
    required LogSource source,
    String? component,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    if (level.index < _minimumLevel.index) return;

    final parsed = _extractTag(message);
    final resolvedComponent = (component ?? parsed.$1).isEmpty
        ? _defaultComponentFor(source)
        : (component ?? parsed.$1);
    final cleanMessage = parsed.$2;

    final ts = DateTime.now().toIso8601String();
    final line =
        '$ts [${_levelToken(level)}] [${source.name.toUpperCase()}] [$resolvedComponent] $cleanMessage';

    final now = DateTime.now();
    if (line == _lastLine && _lastAt != null) {
      final withinWindow = now.difference(_lastAt!) <= _dedupeWindow;
      if (withinWindow) {
        _lastRepeatCount++;
        _lastAt = now;
        return;
      }
    }

    _flushRepeats();

    final colorLine = _colorize(line, level);
    if (level.index >= LogLevel.error.index) {
      stderr.writeln(colorLine);
    } else {
      stdout.writeln(colorLine);
    }

    _writeConsoleGap();

    _writeRaw(line);

    if (error != null) {
      _writeRaw('    error: $error');
    }
    if (stackTrace != null) {
      _writeRaw('    stack: $stackTrace');
    }

    _writeRaw('');

    _lastLine = line;
    _lastLevel = level;
    _lastSource = source;
    _lastRepeatCount = 0;
    _lastAt = now;
  }

  static void _flushRepeats() {
    if (_lastRepeatCount <= 0 || _lastLine == null) return;

    final level = _lastLevel ?? LogLevel.debug;
    final source = _lastSource ?? LogSource.system;
    final ts = DateTime.now().toIso8601String();
    final line =
        '$ts [${_levelToken(level)}] [${source.name.toUpperCase()}] [Logger] (previous line repeated $_lastRepeatCount times)';

    final colorLine = _colorize(line, level);
    if (level.index >= LogLevel.error.index) {
      stderr.writeln(colorLine);
    } else {
      stdout.writeln(colorLine);
    }

    _writeConsoleGap();
    _writeRaw(line);
    _writeRaw('');

    _lastRepeatCount = 0;
  }

  static void _writeConsoleGap() {
    if (stderr.hasTerminal) {
      stderr.writeln('');
    } else if (stdout.hasTerminal) {
      stdout.writeln('');
    } else {
      stdout.writeln('');
    }
  }

  static (String, String) _extractTag(String message) {
    if (message.startsWith('[')) {
      final end = message.indexOf(']');
      if (end > 1) {
        final tag = message.substring(1, end).trim();
        final rest = message.substring(end + 1).trim();
        return (tag, rest);
      }
    }
    return ('', message);
  }

  static String _defaultComponentFor(LogSource source) {
    switch (source) {
      case LogSource.ui:
        return 'UI';
      case LogSource.service:
        return 'Service';
      case LogSource.process:
        return 'Process';
      case LogSource.network:
        return 'Network';
      case LogSource.storage:
        return 'Storage';
      case LogSource.security:
        return 'Security';
      case LogSource.system:
        return 'System';
    }
  }

  static void _writeRaw(String line) {
    if (_fileSink == null) {
      _bufferBeforeInit.add(line);
      return;
    }
    _fileSink!.writeln(line);
  }

  static String _levelToken(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 'TRACE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.log:
        return 'LOG';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  static String _colorize(String line, LogLevel level) {
    final useColor = stdout.supportsAnsiEscapes || stderr.supportsAnsiEscapes;
    if (!useColor) return line;

    final color = _levelColor(level);
    if (color.isEmpty) return line;
    return '$color$line\x1B[0m';
  }

  static String _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return '\x1B[90m'; // bright black
      case LogLevel.debug:
        return '\x1B[36m'; // cyan
      case LogLevel.info:
        return '\x1B[32m'; // green
      case LogLevel.log:
        return '\x1B[37m'; // white
      case LogLevel.warning:
        return '\x1B[33m'; // yellow
      case LogLevel.error:
        return '\x1B[31m'; // red
      case LogLevel.fatal:
        return '\x1B[35m'; // magenta
    }
  }

  static LogLevel _parseMinLevel(String input) {
    switch (input.toUpperCase()) {
      case 'TRACE':
        return LogLevel.trace;
      case 'DEBUG':
        return LogLevel.debug;
      case 'INFO':
        return LogLevel.info;
      case 'LOG':
        return LogLevel.log;
      case 'WARN':
      case 'WARNING':
        return LogLevel.warning;
      case 'ERROR':
        return LogLevel.error;
      case 'FATAL':
        return LogLevel.fatal;
      default:
        return LogLevel.trace;
    }
  }

  static String _platformName() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isLinux) return 'linux';
    if (Platform.isWindows) return 'windows';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    return 'unknown';
  }

  static String _timestampForFile(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');
    return '${dt.year}${two(dt.month)}${two(dt.day)}_${two(dt.hour)}${two(dt.minute)}${two(dt.second)}_${three(dt.millisecond)}';
  }
}
