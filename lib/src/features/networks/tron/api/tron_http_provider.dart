import 'package:http/http.dart' as http;
import 'package:on_chain/tron/tron.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Provider for working with the TRON node
class TronHTTPProvider with TronServiceProvider {
  /// Provider for working with the TRON node
  TronHTTPProvider({
    required this.url,
    http.Client? client,
    this.requestTimeout = CoreConsts.defaultRequestTimeout,
    this.authToken,
  }) : client = client ?? http.Client();

  /// API address
  final String url;

  /// Network client for interaction
  final http.Client client;

  /// Timeout for requests
  final Duration requestTimeout;

  /// Authorization token
  final String? authToken;

  Map<String, String> _headers(TronRequestDetails params) => {
    if (authToken != null && authToken!.isNotEmpty)
      'Authorization': 'Bearer $authToken',
    ...params.headers,
  };

  @override
  Future<TronServiceResponse> doRequest(
    TronRequestDetails params, {
    Duration? timeout,
  }) async {
    if (params.requestMethod.isPost) {
      final response = await client
          .post(
            params.encodeUrl(url),
            headers: _headers(params),
            body: params.encodeBody(),
          )
          .timeout(timeout ?? requestTimeout);
      return params.toResponse(
        response.bodyBytes,
        statusCode: response.statusCode,
      );
    }
    final response = await client
        .get(params.encodeUrl(url), headers: _headers(params))
        .timeout(timeout ?? requestTimeout);
    return params.toResponse(
      response.bodyBytes,
      statusCode: response.statusCode,
    );
  }
}
