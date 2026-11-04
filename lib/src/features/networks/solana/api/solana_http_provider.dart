import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart' as http;
import 'package:on_chain/solana/src/rpc/core/core.dart';
import 'package:on_chain/solana/src/rpc/service/service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Provider for working with the Solana node
///
/// Meant to be long-lived: create it once and share it, so that the http client
/// keeps its connections alive between requests. The `Authorization` header
/// is not stored in the instance - `getAuthorization` is called on every
/// request.
/// The provider never closes the http client, that is up to its owner.
class SolanaHTTPProvider with SolanaServiceProvider {
  /// Provider for working with the Solana node
  SolanaHTTPProvider({
    required this.url,
    http.Client? client,
    this.requestTimeout = CoreConsts.defaultRequestTimeout,
    String? Function()? getAuthorization,
  }) : client = client ?? http.Client(),
       _getAuthorization = getAuthorization;

  /// API address
  final String url;

  /// Network client for interaction
  final http.Client client;

  /// Timeout for requests
  final Duration requestTimeout;

  /// Current `Authorization` header value with its scheme (`Bearer …`,
  /// `DPoP …`), sent as is: null or empty - no Authorization header
  final String? Function()? _getAuthorization;

  @override
  Future<BaseServiceResponse> doRequest(
    SolanaRequestDetails params, {
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
}
