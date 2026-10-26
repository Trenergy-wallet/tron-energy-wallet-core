import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart' as http;
import 'package:on_chain/solana/src/rpc/core/core.dart';
import 'package:on_chain/solana/src/rpc/service/service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Provider for working with the Solana node
///
/// Meant to be long-lived: create it once and share it, so that the http client
/// keeps its connections alive between requests. The auth token is not
/// stored in the instance - `getAuthToken` is called on every request.
/// The provider never closes the http client, that is up to its owner.
class SolanaHTTPProvider with SolanaServiceProvider {
  /// Provider for working with the Solana node
  SolanaHTTPProvider({
    required this.url,
    http.Client? client,
    this.requestTimeout = CoreConsts.defaultRequestTimeout,
    String? Function()? getAuthToken,
  }) : client = client ?? http.Client(),
       _getAuthToken = getAuthToken;

  /// API address
  final String url;

  /// Network client for interaction
  final http.Client client;

  /// Timeout for requests
  final Duration requestTimeout;

  /// Current auth token: null or empty - no Authorization header
  final String? Function()? _getAuthToken;

  @override
  Future<BaseServiceResponse> doRequest(
    SolanaRequestDetails params, {
    Duration? timeout,
  }) async {
    final authToken = _getAuthToken?.call();
    final response = await client
        .post(
          params.encodeUrl(url),
          headers: {
            if (authToken != null && authToken.isNotEmpty)
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
