// It is for testing
// ignore_for_file: avoid_print

import 'dart:developer' as developer;

import 'package:logging/logging.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';

const _maxLength = 100000;
const Level _minimumLogLevel = Level.INFO;

/// Class for displaying logs inside the app
/// Resets after app restart
/// All new events are also printed to the console
final class InAppLogger {
  InAppLogger._();

  /// Singleton InAppLogger
  static final InAppLogger instance = InAppLogger._();

  final _log = StringBuffer();

  /// In tests, simply output prints
  bool inTest = false;

  /// Add a new line to the log and console
  void _addToLog({
    required String method,
    required Object line,
    Level level = Level.INFO,
    Object? error,
    StackTrace? stacktrace,
  }) {
    if (inTest) {
      print('[$method] $line');
      return;
    }
    if (level >= _minimumLogLevel) {
      // Limit log length to 100,000 characters and on overflow
      // keep only the most recent data (last 90,000 characters)
      if (_log.length > _maxLength) {
        // To avoid cutting off the log mid-line, find the start of the line
        // at which to trim the log
        final pos = _log.toString().indexOf(
          RegExp(r'\[\d+:\d+:\d+] \['),
          (_maxLength * 0.1).toInt(),
        );
        final savedPart = _log.toString().substring(pos, _maxLength);
        _log
          ..clear()
          ..write(savedPart);
      }

      final now = DateTime.now();
      final datetime =
          '${_toDoubleDigits(now.hour)}:${_toDoubleDigits(now.minute)}:'
          '${_toDoubleDigits(now.second)}';
      _log
        ..write('[$datetime] [$method] ${_getLogSymbol(level)}')
        // Limit length of a single logged message
        ..writeln(line.toString().maxLen(30000));
      developer.log(
        '${_getLogSymbol(level)} $line',
        name: '$datetime] [$method',
        error: error,
        stackTrace: stacktrace,
        level: level.value,
      );
    }
  }

  /// Get the current log value
  String get getLog => _log.toString();

  /// Clear the log
  void cleanLog() => _log.clear();

  /// Save a regular informational message without prefix
  void logInfoMessage(String method, Object line) =>
      _addToLog(method: method, line: line);

  /// Save a warning - something went wrong but protection worked
  /// (e.g., DTO set a default value in a required field)
  void logWarning(String method, Object line) =>
      _addToLog(method: method, line: line, level: Level.WARNING);

  /// Error - something went wrong
  void logError(
    String method,
    Object line, [
    Object? error,
    StackTrace? stacktrace,
  ]) => _addToLog(
    method: method,
    line: line,
    level: Level.SEVERE,
    error: error,
    stacktrace: stacktrace,
  );

  /// Something terrible happened that significantly affects the app’s
  /// functionality
  void logCriticalError(
    String method,
    Object line, [
    Object? error,
    StackTrace? stacktrace,
  ]) => _addToLog(
    method: method,
    line: line,
    level: Level.SHOUT,
    error: error,
    stacktrace: stacktrace,
  );
}

String _toDoubleDigits(int v) {
  if (v < 10) {
    return '0$v';
  } else {
    return v.toString();
  }
}

String _getLogSymbol(Level level) {
  switch (level) {
    case Level.WARNING: // WARNING
      return '❕';
    case Level.SEVERE: // SEVERE
      return '❗️';
    case Level.SHOUT: // SHOUT
      return '❗❗❗';
    default:
      return '';
  }
}
