import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:http/http.dart' as http;
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Http service of a [BlockbookProvider] (Bitcoin, Litecoin)
///
/// Meant to be long-lived: create it once and share it, so that the http client
/// keeps its connections alive between requests. The `Authorization` header
/// is not stored in the instance - `getAuthorization` is called on every
/// request.
/// The provider never closes the http client, that is up to its owner.
class BlockbookHTTPProvider implements BlockbookServiceProvider {
  /// Http service of a [BlockbookProvider]
  ///
  /// [url] is the Blockbook root, the one `/api/v2/...` is appended to
  BlockbookHTTPProvider({
    required this.url,
    http.Client? client,
    this.requestTimeout = CoreConsts.defaultRequestTimeout,
    String? Function()? getAuthorization,
  }) : client = client ?? http.Client(),
       _getAuthorization = getAuthorization;

  /// Blockbook root address
  final String url;

  /// Network client for interaction
  final http.Client client;

  /// Timeout for requests
  final Duration requestTimeout;

  /// Current `Authorization` header value with its scheme (`Bearer …`,
  /// `DPoP …`), sent as is: null or empty - no Authorization header
  final String? Function()? _getAuthorization;

  Map<String, String> _headers(BlockbookRequestDetails params) {
    final authorization = _getAuthorization?.call();
    return {
      if (authorization != null && authorization.isNotEmpty)
        'Authorization': authorization,
      ...params.headers,
    };
  }

  @override
  Future<BaseServiceResponse> doRequest(
    BlockbookRequestDetails params, {
    Duration? timeout,
  }) async {
    final request = http.Request(
      params.requestMethod.methodName,
      params.encodeUrl(url),
    )..headers.addAll(_headers(params));
    final body = params.encodeBody();
    if (body != null) request.bodyBytes = body;
    final response = await client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(timeout ?? requestTimeout);
    return params.toResponse(
      response.bodyBytes,
      statusCode: response.statusCode,
    );
  }

  @override
  Future<BaseServiceSubscribtionResponse> doSubscribtionRequest({
    required BlockbookRequestDetails params,
    required BaseServiceSubscribtionRequest<
      dynamic,
      dynamic,
      BaseSubscribtionEvent<dynamic>,
      BlockbookRequestDetails
    >
    request,
    Duration? timeout,
  }) => throw UnsupportedError('Subscriptions are not supported over HTTP.');

  @override
  Future<List<int>> doGrpcRequest(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) => throw UnsupportedError('gRPC is not supported by Blockbook.');

  @override
  Stream<List<int>> doGrpcRequestStream(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) => throw UnsupportedError('gRPC is not supported by Blockbook.');

  @override
  Future<Stream<List<int>>> doGrpcRequestStreamAsync(
    BaseGRPCServiceRequestParams params, {
    Duration? timeout,
  }) => throw UnsupportedError('gRPC is not supported by Blockbook.');
}
