// ignore_for_file: avoid_print

import 'dart:developer' as developer;

import 'package:logging/logging.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';

const _maxLength = 100000;
const Level _minimumLogLevel = Level.INFO;

/// Класс для показа лога внутри приложения
/// Сбрасывается после перезапуска приложения
/// Все новые события также выводятся в консоль
final class InAppLogger {
  InAppLogger._();

  /// Синглтон InAppLogger
  static final InAppLogger instance = InAppLogger._();

  final _log = StringBuffer();

  /// В тестах просто выводим принты
  bool inTest = false;

  /// Добавить новую строку в лог и консоль
  void _addToLog({
    required String method,
    // TODO(ivn): Отрефракторить для того чтобы в поле line не нужно было
    // снаружи передавать ошибку
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
      // Ограничим длину лога 100 000 символов и при переполнении будем
      // оставлять только свежие данные (последние 90 000 символов)
      if (_log.length > _maxLength) {
        // Чтобы лог не обрывался посередине строки, найдем начало строки, до
        // которой будем обрезать лог
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
        // ограничим длину одного логируемого сообщения
        ..writeln(line.toString().maxLen(30000));
      // рефреш тут не делаем, тк может оказаться, что мы не в дереве
      developer.log(
        '${_getLogSymbol(level)} $line',
        name: '$datetime] [$method',
        error: error,
        stackTrace: stacktrace,
        level: level.value,
      );
    }
  }

  /// Получить текущее значение лога
  String get getLog => _log.toString();

  /// Очистить лог
  void cleanLog() => _log.clear();

  /// Сохраняем обычное информационное сообщение без префикса
  void logInfoMessage(String method, Object line) =>
      _addToLog(method: method, line: line);

  /// Сохраняем предупреждение - чтото пошло не так но защита сработала
  /// (например DTO в required поле поставило значение по умолчанию)
  void logWarning(String method, Object line) =>
      _addToLog(method: method, line: line, level: Level.WARNING);

  /// Ошибка - чтото пошло не так
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

  /// Случилось что-то ужасное, что существенно влияет на работоспособность
  /// приложения
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
