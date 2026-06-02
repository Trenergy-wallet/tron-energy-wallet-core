import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart' as http;
import 'package:on_chain/solana/src/rpc/core/core.dart';
import 'package:on_chain/solana/src/rpc/service/service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Provider for working with the TRON node
class SolanaHTTPProvider implements SolanaServiceProvider {
  /// Provider for working with the TRON node
  SolanaHTTPProvider({
    required this.url,
    http.Client? client,
    this.defaultRequestTimeout = CoreConsts.defaultRequestTimeout,
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
  Future<BaseServiceResponse<T>> doRequest<T>(
    SolanaRequestDetails params, {
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
