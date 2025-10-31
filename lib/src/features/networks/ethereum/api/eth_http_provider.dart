import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart';
import 'package:on_chain/on_chain.dart';

/// Http provider for Ethereum
class EthereumHTTPProvider with EthereumServiceProvider {
  /// Http provider for Ethereum
  EthereumHTTPProvider(
    this.url,
    this.authToken, {
    Client? client,
    this.defaultTimeOut = const Duration(seconds: 30),
  }) : client = client ?? Client();

  /// Api url
  final String url;

  /// Http client
  final Client client;

  /// Timeout
  final Duration defaultTimeOut;

  /// Auth token
  final String? authToken;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(
    EthereumRequestDetails params, {
    Duration? timeout,
  }) async {
    final response = await client
        .post(
          params.toUri(url),
          headers: {
            ...params.headers,
            if (authToken != null && authToken!.isNotEmpty)
              'Authorization': 'Bearer $authToken',
          },
          body: params.body(),
        )
        .timeout(timeout ?? defaultTimeOut);
    return params.toResponse(response.bodyBytes, response.statusCode);
  }
}
