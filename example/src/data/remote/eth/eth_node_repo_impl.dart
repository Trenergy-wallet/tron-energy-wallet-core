import 'package:dio/dio.dart';
import 'package:tr_logger/tr_logger.dart' show InAppLogger;
import 'package:tron_energy_wallet_core/src/application/repo/remote/14_proxy/eth_node_repo_base.dart';
import 'package:tron_energy_wallet_core/src/core/network/eth_node_client/client.cg.dart'
    show ETHNodeClient;
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../../../../example_trust_sdk.dart' show ethApiKey;

/// ETHNodeRepoImpl
final class ETHNodeRepoImpl implements ETHNodeRepo {
  /// Singleton instance of ETHNodeRepoImpl
  factory ETHNodeRepoImpl() => _singleton;

  ETHNodeRepoImpl._internal()
    : _client = ETHNodeClient(
        Dio(BaseOptions(baseUrl: 'https://rpc.ankr.com/'))
          ..interceptors.add(const AppLogInterceptor()),
      );

  static final ETHNodeRepoImpl _singleton = ETHNodeRepoImpl._internal();

  final ETHNodeClient _client;

  @override
  Future<Either<AppExceptionWithCode, String>> sendRawTransaction({
    required String rawTransaction,
    int id = 1,
  }) async {
    try {
      final txInfo = await _client.sendRawTransaction(
        apiToken: ethApiKey,
        body: {
          'jsonrpc': '2.0',
          'method': 'eth_sendRawTransaction',
          'params': [rawTransaction],
          'id': id,
        },
      );
      if (txInfo.error != null) throw Exception(txInfo.error);
      return Right(txInfo.result!);
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
    }
  }
}

/// Interceptor для логирования
class AppLogInterceptor extends Interceptor {
  /// Interceptor для логирования
  const AppLogInterceptor();

  // static const _name = 'LogChangedHeadersInterceptor';

  static String _lastHeaders = '';

  InAppLogger get _logger => InAppLogger();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _logger.logInfoMessage('HTTP REQUEST', _combineLogLineFromOptions(options));

    if (!(options.headers.toString() == _lastHeaders)) {
      _lastHeaders = options.headers.toString();

      _logger.logInfoMessage(
        'HEADERS CHANGED',
        '❕New headers ❕: $_lastHeaders',
      );
    }
    return handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final respString = response.toString();
    final msg = respString.length < 500
        ? respString
        : respString.substring(0, 500);
    _logger.logInfoMessage('HTTP RESPONSE', msg);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = AppDioException(dioException: err);
    _logger.logError(
      'HTTP ERROR',
      'Request options: ${_combineLogLineFromOptions(err.requestOptions)}\n'
          'Error: $appException',
    );
    super.onError(err, handler);
  }

  String _combineLogLineFromOptions(RequestOptions options) {
    var logLine = '${options.method} ${options.uri}';
    if (options.data != null) {
      logLine += '\ndata:${options.data}';
    }
    if (options.extra.isNotEmpty) {
      logLine += ' \nextra:${options.extra}';
    }
    return logLine;
  }
}
