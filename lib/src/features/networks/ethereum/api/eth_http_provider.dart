import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Http provider for Ethereum
///
/// Meant to be long-lived: create it once and share it, so that the http client
/// keeps its connections alive between requests. The `Authorization` header
/// is not stored in the instance - `getAuthorization` is called on every
/// request.
/// The provider never closes the http client, that is up to its owner.
class EthereumHTTPProvider with EthereumServiceProvider {
  /// Http provider for Ethereum
  EthereumHTTPProvider(
    this.url, {
    Client? client,
    String? Function()? getAuthorization,
    this.requestTimeout = CoreConsts.defaultRequestTimeout,
  }) : client = client ?? Client(),
       _getAuthorization = getAuthorization;

  /// Api url
  final String url;

  /// Http client
  final Client client;

  /// Timeout for requests
  final Duration requestTimeout;

  /// Current `Authorization` header value with its scheme (`Bearer …`,
  /// `DPoP …`), sent as is: null or empty - no Authorization header
  final String? Function()? _getAuthorization;

  @override
  Future<BaseServiceResponse> doRequest(
    EthereumRequestDetails params, {
    Duration? timeout,
  }) async {
    final authorization = _getAuthorization?.call();
    final response = await client
        .post(
          params.encodeUrl(url),
          headers: {
            if (authorization != null && authorization.isNotEmpty)
              'Authorization': authorization,
            ...params.headers,
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
