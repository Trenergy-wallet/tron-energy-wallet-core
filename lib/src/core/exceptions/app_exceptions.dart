import 'package:dio/dio.dart' show DioException;
import 'package:tron_energy_wallet_core/src/core/core.dart';
import 'package:tron_energy_wallet_core/src/domain/models/info/estimate_fee.cg.dart';

/// Base exception class containing
///
/// Message [message]
/// Error code [code]
/// StackTrace [stackTrace]
abstract class AppExceptionWithCode implements Exception {
  /// Base exception class containing
  ///
  /// [message] - message
  /// [code] - error code
  /// [stackTrace] - StackTrace where the error was thrown
  AppExceptionWithCode({
    required this.message,
    required this.code,
    this.stackTrace,
  });

  /// Error message
  final String message;

  /// Error code
  final ExceptionCode code;

  /// StackTrace
  final StackTrace? stackTrace;
}

/// PIN code decryption error
class IncorrectPinCodeException implements Exception {
  /// PIN code decryption error
  IncorrectPinCodeException();

  @override
  String toString() {
    return 'IncorrectPinCodeException: Incorrect pin-code';
  }
}

/// General type exception
class AppException extends AppExceptionWithCode implements Exception {
  /// General type exception
  AppException({String? message, ExceptionCode? code, super.stackTrace})
    : super(message: message ?? '', code: code ?? ExceptionCode.generalError);

  @override
  String toString() {
    return 'AppException: ${message.isNotEmpty ? message : code.description}, '
        'code: $code';
  }
}

/// Exception for errors from backend (validations)
class AppBackendException extends AppExceptionWithCode implements Exception {
  /// Exception for errors from backend (validations)
  AppBackendException({String? message, ExceptionCode? code, super.stackTrace})
    : super(
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

/// Exception for errors from backend (Status code is not 200)
class AppDioException extends AppExceptionWithCode implements Exception {
  /// Exception for errors from backend (Status code is not 200)
  AppDioException({required this.dioException})
    : super(
        message: () {
          final data = dioException.response?.data;
          if (data is Map<String, dynamic> && data.containsKey('error')) {
            return data['error'].toString();
          }
          final msg = data.toString();
          return msg.length < 500 ? msg : msg.substring(0, 500);
        }(),
        code: ExceptionCode.fromDioException(dioException),
        stackTrace: dioException.stackTrace,
      );

  /// Dio exception
  final DioException dioException;

  /// Path (endpoint)
  String get path => dioException.requestOptions.path;

  /// Server response code
  int get statusCode =>
      dioException.response?.statusCode ?? CoreConsts.invalidIntValue;

  /// Timeout error
  bool get isConnectionError => code == ExceptionCode.connectionTimeout;

  @override
  String toString() {
    return 'AppDioException: dioType: ${dioException.type}, path: $path, '
        'status code: $statusCode, code: $code, '
        'message: ${message.isNotEmpty ? message : code.description}';
  }
}

/// Exception when attempting to access rpc/node
class AppRpcException extends AppExceptionWithCode implements Exception {
  /// Exception when attempting to access rpc/node
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

/// Exception for errors from the ERC-4337 bundler / ERC-20 paymaster
///
/// [ExceptionCode.insufficientBalanceToPayFee] here means the paymaster
/// could not charge the account for gas in `postOp`: the transfer itself is
/// fine, the balance just does not cover the fee on top of it. That outcome
/// is deterministic for the current balance and gas price, so the caller
/// must not retry - every attempt costs another paid round.
/// Everything else stays [ExceptionCode.rpcError] and may be transient
/// (HTTP 5xx and 429 from the bundler arrive this way)
class AppBundlerRpcException extends AppExceptionWithCode implements Exception {
  /// Exception for errors from the ERC-4337 bundler / ERC-20 paymaster
  AppBundlerRpcException(this.bundlerError, {super.stackTrace})
    : super(message: bundlerError.message, code: _codeFor(bundlerError));

  /// Solady `SafeTransferLib.TransferFromFailed()` selector
  ///
  /// The ERC-20 paymaster pulls the gas fee from the account with
  /// `transferFrom`, so this selector inside a revert means the balance did
  /// not cover the fee
  static const transferFromFailedSelector = '0x7939f424';

  /// Original error of the bundler client
  final BundlerRpcError bundlerError;

  /// ERC-4337 error code (`AA50` and so on), when the bundler reported one
  String? get aaCode => bundlerError.aaErrorCode;

  /// JSON-RPC error code, or the HTTP status of a non-200 response
  int get rpcCode => bundlerError.code;

  /// The paymaster failed to take the gas fee from the account
  bool get cannotChargeGas =>
      code == ExceptionCode.insufficientBalanceToPayFee;

  /// `AA50`/`AA51` are postOp reverts - the stage where the ERC-20
  /// paymaster charges the account
  static ExceptionCode _codeFor(BundlerRpcError e) {
    final cannotCharge =
        e.aaErrorCode == 'AA50' ||
        e.aaErrorCode == 'AA51' ||
        e.toString().contains(transferFromFailedSelector);
    return cannotCharge
        ? ExceptionCode.insufficientBalanceToPayFee
        : ExceptionCode.rpcError;
  }

  @override
  String toString() {
    return 'AppBundlerRpcException: code: $code, rpcCode: $rpcCode'
        '${aaCode == null ? '' : ', $aaCode'}, message: $message';
  }
}

/// Exception when attempting to access an unsupported blockchain
class AppBlockchainIsNotSupportedException extends AppExceptionWithCode
    implements Exception {
  /// Exception when attempting to access an unsupported blockchain
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

/// Exception thrown when attempting to process with an incorrectly selected
/// blockchain
class AppIncorrectBlockchainException extends AppExceptionWithCode
    implements Exception {
  /// Exception thrown when attempting to process with an incorrectly selected
  /// blockchain
  AppIncorrectBlockchainException(
    String expectedBlockchain,
    String actualBlockchain,
  ) : super(
        message:
            'incorrect blockchain: expected $expectedBlockchain got'
            ' $actualBlockchain',
        code: ExceptionCode.incorrectBlockchain,
      );

  @override
  String toString() {
    return 'AppIncorrectBlockchainException: $message,'
        ' code: $code';
  }
}

/// Exception thrown when attempting to process while blockchain commission has
/// changed
class AppFeeChangedException extends AppExceptionWithCode implements Exception {
  /// Exception thrown when attempting to process while blockchain commission
  /// has changed
  AppFeeChangedException(
    EstimateFeeModel selectedCommission,
    EstimateFeeModel actualCommission,
  ) : super(
        message:
            'network commission changed: old $selectedCommission new'
            ' $actualCommission',
        code: ExceptionCode.feeChanged,
      );

  @override
  String toString() {
    return 'AppCommissionChangedException: message: $message,'
        ' code: $code';
  }
}

/// Raw exception with possible stack trace in the message body
class AppRawException extends AppExceptionWithCode implements Exception {
  /// Raw exception with possible stack trace in the message body
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
