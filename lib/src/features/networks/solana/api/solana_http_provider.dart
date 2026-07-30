import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart' as http;
import 'package:on_chain/solana/src/rpc/core/core.dart';
import 'package:on_chain/solana/src/rpc/service/service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Provider for working with the Solana node
class SolanaHTTPProvider with SolanaServiceProvider {
  /// Provider for working with the Solana node
  SolanaHTTPProvider({
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

  @override
  Future<BaseServiceResponse> doRequest(
    SolanaRequestDetails params, {
    Duration? timeout,
  }) async {
    final response = await client
        .post(
          params.encodeUrl(url),
          headers: {
            if (authToken != null && authToken!.isNotEmpty)
              'Authorization': 'Bearer $authToken',
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
}
