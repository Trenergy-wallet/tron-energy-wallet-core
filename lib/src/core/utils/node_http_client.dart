import 'package:http/http.dart' as http;
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/core/utils/logging_http_client.dart';

/// HTTP client for a node provider: [client] passed by the caller (e.g. one
/// that adds DPoP proofs) and/or logging
///
/// Null - neither is set, the provider creates its own plain client
http.Client? nodeHttpClient({http.Client? client, TRLogger? logger}) {
  if (logger == null) return client;
  return LoggingHttpClient(client ?? http.Client(), logger: logger);
}

/// [http.Client] decorator that never closes the client it wraps
///
/// For a client shared by several consumers when some of them close clients
/// after use (permissionless does): the shared one is closed only by its owner
class UnclosableHttpClient extends http.BaseClient {
  /// [http.Client] decorator that never closes the client it wraps
  UnclosableHttpClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request);

  /// Does nothing: the wrapped client belongs to the caller
  @override
  void close() {}
}
