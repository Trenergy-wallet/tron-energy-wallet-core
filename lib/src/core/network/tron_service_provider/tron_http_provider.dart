import 'package:http/http.dart' as http;
import 'package:on_chain/tron/tron.dart';

/// Provider for working with the TRON node
class TronHTTPProvider implements TronServiceProvider {
  /// Provider for working with the TRON node
  TronHTTPProvider({
    required this.url,
    http.Client? client,
    this.defaultRequestTimeout = const Duration(seconds: 30),
    this.authToken,
  }) : client = client ?? http.Client();

  /// API address
  final String url;

  /// Network client for interaction
  final http.Client client;

  /// Timeout for requests
  final Duration defaultRequestTimeout;

  /// Authorization token
  final String? authToken;

  @override
  Future<TronServiceResponse<T>> doRequest<T>(
    TronRequestDetails params, {
    Duration? timeout,
  }) async {
    final response = await client
        .post(
          params.toUri(url),
          headers: {
            if (authToken != null && authToken!.isNotEmpty)
              'Authorization': 'Bearer $authToken',
            ...params.headers,
          },
          body: params.body(),
        )
        .timeout(timeout ?? defaultRequestTimeout);
    return params.toResponse(response.bodyBytes, response.statusCode);
  }
}
