import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tr_logger/tr_logger.dart';

/// A transparent [http.Client] decorator that logs every request and response.
///
/// Response bodies are buffered in memory to be logged and then re-emitted -
/// acceptable for JSON-RPC payloads, which are small.
class LoggingHttpClient extends http.BaseClient {
  /// A transparent [http.Client] decorator that logs every request/response.
  LoggingHttpClient(
    this._inner, {
    required TRLogger logger,
    this.maxBodyLength = 1000,
  }) : _logger = logger;

  final http.Client _inner;
  final TRLogger _logger;

  /// Request/response bodies are truncated to this many characters in the log.
  final int maxBodyLength;

  static const _requestTag = 'NODE HTTP →';
  static const _responseTag = 'NODE HTTP ←';
  static const _errorTag = 'NODE HTTP ✕';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _logRequest(request);
    try {
      final response = await _inner.send(request);
      // The stream can be read only once, so buffer it, log it and re-emit.
      final bytes = await response.stream.toBytes();
      _logResponse(request, response, bytes);
      return http.StreamedResponse(
        Stream<List<int>>.value(bytes),
        response.statusCode,
        contentLength: bytes.length,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } on Object catch (e) {
      _logger.logError(_errorTag, '${request.method} ${request.url}\n$e');
      rethrow;
    }
  }

  void _logRequest(http.BaseRequest request) {
    final buffer = StringBuffer('${request.method} ${request.url}');
    if (request is http.Request && request.body.isNotEmpty) {
      final method = _jsonRpcMethod(request.body);
      if (method != null) buffer.write(' [$method]');
      buffer.write('\n${_truncate(request.body)}');
    }
    _logger.logInfoMessage(_requestTag, buffer.toString());
  }

  void _logResponse(
    http.BaseRequest request,
    http.StreamedResponse response,
    Uint8List bytes,
  ) {
    final body = _truncate(utf8.decode(bytes, allowMalformed: true));
    _logger.logInfoMessage(
      _responseTag,
      '${response.statusCode} ${request.url}\n$body',
    );
  }

  /// Extracts the JSON-RPC `method` from a request body for a readable log
  /// line (e.g. `eth_sendUserOperation`). Handles single and batch requests;
  /// returns null for non JSON-RPC bodies.
  String? _jsonRpcMethod(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded['method']?.toString();
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => e['method'])
            .join(', ');
      }
    } on FormatException {
      // Not JSON - nothing to extract.
    }
    return null;
  }

  String _truncate(String value) => value.length > maxBodyLength
      ? '${value.substring(0, maxBodyLength)}…(${value.length})'
      : value;

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
