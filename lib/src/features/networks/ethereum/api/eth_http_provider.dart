import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Http provider for Ethereum
class EthereumHTTPProvider with EthereumServiceProvider {
  /// Http provider for Ethereum
  EthereumHTTPProvider(
    this.url,
    this.authToken, {
    Client? client,
    this.requestTimeout = CoreConsts.defaultRequestTimeout,
  }) : client = client ?? Client();

  /// Api url
  final String url;

  /// Http client
  final Client client;

  /// Timeout for requests
  final Duration requestTimeout;

  /// Auth token
  final String? authToken;

  @override
  Future<BaseServiceResponse> doRequest(
    EthereumRequestDetails params, {
    Duration? timeout,
  }) async {
    final response = await client
        .post(
          params.encodeUrl(url),
          headers: {
            ...params.headers,
            if (authToken != null && authToken!.isNotEmpty)
              'Authorization': 'Bearer $authToken',
          },
          body: params.encodeBody(),
        )
        .timeout(timeout ?? requestTimeout);
    return params.toResponse(
      response.bodyBytes,
      statusCode: response.statusCode,
    );
  }

  @override
  Future<BaseServiceSubscribtionResponse> doSubscribtionRequest({
    required EthereumRequestDetails params,
    required BaseServiceSubscribtionRequest<
      dynamic,
      dynamic,
      BaseSubscribtionEvent<dynamic>,
      EthereumRequestDetails
    >
    request,
    Duration? timeout,
  }) {
    throw UnsupportedError('Subscriptions are not supported over HTTP.');
  }
}
