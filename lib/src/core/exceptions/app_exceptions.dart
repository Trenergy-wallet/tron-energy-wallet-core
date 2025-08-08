import 'package:dio/dio.dart' show DioException;
import 'package:tron_energy_wallet_core/src/core/core.dart';

/// Базовый класс исключений, содержащий
///
/// сообщение [message]
/// код ошибки [code]
/// StackTrace [stackTrace]
abstract class AppExceptionWithCode implements Exception {
  /// Базовыйы класс исключений содержащий
  ///
  /// [message] - сообщение
  /// [code] - код ошибки
  /// [stackTrace] - StackTrace где была выкинута ошибка
  AppExceptionWithCode({
    required this.message,
    required this.code,
    this.stackTrace,
  });

  /// Сообщение об ошибке
  final String message;

  /// Код ошибки
  final ExceptionCode code;

  /// StackTrace. Сохраняем для обработки при оборачивании в Either
  final StackTrace? stackTrace;
}

/// Ошибка расшифровки пин-кода
class IncorrectPinCodeException implements Exception {
  /// Ошибка расшифровки пин-кода
  IncorrectPinCodeException();

  @override
  String toString() {
    return 'IncorrectPinCodeException: Incorrect pin-code';
  }
}

/// Исключение общего типа
class AppException extends AppExceptionWithCode implements Exception {
  /// Исключение общего типа
  AppException({
    String? message,
    ExceptionCode? code,
    super.stackTrace,
  }) : super(
          message: message ?? '',
          code: code ?? ExceptionCode.generalError,
        );

  @override
  String toString() {
    return 'AppException: ${message.isNotEmpty ? message : code.description}, '
        'code: $code';
  }
}

/// Исключение, получаемое при ошибках бекенда
class AppBackendException extends AppExceptionWithCode implements Exception {
  /// Исключение, получаемое при ошибках бекенда
  AppBackendException({
    String? message,
    ExceptionCode? code,
    super.stackTrace,
  }) : super(
          message: message ?? '',
          code: code ?? ExceptionCode.backendGeneralError,
        );

  @override
  String toString() {
    return 'AppBackendException: '
        'code: $code '
        '${message.isNotEmpty ? message : code.description}';
  }
}

/// Исключение, получаемое при ошибках бекенда
class AppDioException extends AppExceptionWithCode implements Exception {
  /// Исключение, получаемое при ошибках бекенда
  AppDioException({
    required this.dioException,
  }) : super(
          message: () {
            final data = dioException.response?.data;
            if (data is Map<String, dynamic> && data.containsKey('error')) {
              return data['error'].toString();
            }
            // Ограничим длину в сообщении чтобы не всю портянку стактрейса
            // ларавела передавать
            final msg = data.toString();
            return msg.length < 500 ? msg : msg.substring(0, 500);
          }(),
          code: ExceptionCode.fromDioException(dioException),
          stackTrace: dioException.stackTrace,
        );

  /// Исключение от дио
  final DioException dioException;

  /// Path (endpoint)
  String get path => dioException.requestOptions.path;

  /// Код ответа сервера
  int get statusCode =>
      dioException.response?.statusCode ?? CoreConsts.invalidIntValue;

  /// Ошибка по таймауту
  bool get isConnectionError => code == ExceptionCode.connectionTimeout;

  @override
  String toString() {
    return 'AppDioException: dioType: ${dioException.type}, path: $path, '
        'status code: $statusCode, code: $code, '
        'message: ${message.isNotEmpty ? message : code.description}';
  }
}

/// Исключение при попытках обратиться к rpc/node
class AppRpcException extends AppExceptionWithCode implements Exception {
  /// Исключение при попытках обратиться к rpc/node
  AppRpcException({
    required super.message,
    ExceptionCode? code,
    super.stackTrace,
  }) : super(code: code ?? ExceptionCode.rpcError);

  @override
  String toString() {
    return 'AppRpcException: $message, code: $code';
  }
}

/// Исключение при попытках обратиться к неподдерживаему блокчейну
class AppBlockchainIsNotSupportedException extends AppExceptionWithCode
    implements Exception {
  /// Исключение при попытках обратиться к неподдерживаему блокчейну
  AppBlockchainIsNotSupportedException(String appBlockchain)
      : super(
          message: '$appBlockchain is not supported',
          code: ExceptionCode.blockchainIsNotSupported,
        );

  @override
  String toString() {
    return 'AppBlockchainIsNotSupportedException: $message,'
        ' code: $code';
  }
}

/// Исключение при попытках обратиться к неподдерживаему блокчейну
class AppIncorrectBlockchainException extends AppExceptionWithCode
    implements Exception {
  /// Исключение при попытках обратиться к неподдерживаему блокчейну
  AppIncorrectBlockchainException(
    String expectedBlockchain,
    String actualBlockchain,
  ) : super(
          message: 'incorrect blockchain: expected $expectedBlockchain got'
              ' $actualBlockchain',
          code: ExceptionCode.incorrectBlockchain,
        );

  @override
  String toString() {
    return 'AppIncorrectBlockchainException: $message,'
        ' code: $code';
  }
}

/// Сырое исключение с возможным стактрейсом в теле сообщения.
/// НЕ ПОКАЗЫВАЕМ ПОЛЬЗОВАТЕЛЮ
class AppRawException extends AppExceptionWithCode implements Exception {
  /// Сырое исключение с возможным стактрейсом в теле сообщения.
  /// НЕ ПОКАЗЫВАЕМ ПОЛЬЗОВАТЕЛЮ
  AppRawException({
    required super.message,
    ExceptionCode? code,
    super.stackTrace,
  }) : super(code: code ?? ExceptionCode.rawException);

  @override
  String toString() {
    return 'AppRawException: code: $code, message: $message';
  }
}
