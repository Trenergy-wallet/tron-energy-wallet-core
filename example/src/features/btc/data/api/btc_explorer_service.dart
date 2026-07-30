import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:http/http.dart' as http;
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// HTTP service for the bitcoin_base providers (mempool.space / BlockCypher).
///
/// Since bitcoin_base 7.2.0 the Mempool and BlockCypher APIs use the same
/// request/response contract as Electrum: the service only performs the
/// transport, and decoding is handled by [BitcoinRequestDetails.toResponse].
class BitcoinApiService with BitcoinServiceProvider {
  /// HTTP service for the bitcoin_base providers.
  BitcoinApiService(
    this.url, {
    http.Client? client,
    this.defaultRequestTimeout = CoreConsts.defaultRequestTimeout,
  }) : _client = client ?? http.Client();

  /// Base url of the explorer api, see [BtcApiConst.getUrl].
  final String url;

  /// Timeout for requests.
  final Duration defaultRequestTimeout;

  final http.Client _client;

  @override
  Future<BaseServiceResponse> doRequest(
    BitcoinRequestDetails params, {
    Duration? timeout,
  }) async {
    final response = params.requestMethod.isGet
        ? await _client
              .get(params.encodeUrl(url), headers: params.headers)
              .timeout(timeout ?? defaultRequestTimeout)
        : await _client
              .post(
                params.encodeUrl(url),
                headers: params.headers,
                body: params.encodeBody(),
              )
              .timeout(timeout ?? defaultRequestTimeout);
    return params.toResponse(
      response.bodyBytes,
      statusCode: response.statusCode,
    );
  }
}
