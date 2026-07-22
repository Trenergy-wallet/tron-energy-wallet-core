import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Captures log lines instead of persisting/printing them.
class _CapturingLogger implements TRLogger {
  final List<({String tag, String line})> entries = [];

  @override
  void logInfoMessage(String method, Object line) =>
      entries.add((tag: method, line: line.toString()));

  @override
  void logWarning(String method, Object line) =>
      entries.add((tag: method, line: line.toString()));

  @override
  void logError(
    String method,
    Object line, [
    Object? error,
    StackTrace? stacktrace,
  ]) => entries.add((tag: method, line: line.toString()));

  @override
  void logCriticalError(
    String method,
    Object line, [
    Object? error,
    StackTrace? stacktrace,
  ]) => entries.add((tag: method, line: line.toString()));

  @override
  bool get usePrint => true;

  @override
  String get getLog => entries.map((e) => '${e.tag} ${e.line}').join('\n');

  @override
  void cleanLog() => entries.clear();
}

void main() {
  final uri = Uri.parse('https://node.example/rpc');

  test('logs request (JSON-RPC method) and response, re-emits body', () async {
    final logger = _CapturingLogger();
    final inner = MockClient(
      (_) async => http.Response('{"jsonrpc":"2.0","result":"0x1"}', 200),
    );
    final client = LoggingHttpClient(inner, logger: logger);

    final res = await client.post(
      uri,
      body: '{"jsonrpc":"2.0","method":"eth_getBalance","id":1}',
    );

    // Body still readable by the caller despite being buffered for the log.
    expect(res.statusCode, 200);
    expect(jsonDecode(res.body), {'jsonrpc': '2.0', 'result': '0x1'});

    final request = logger.entries.firstWhere((e) => e.tag.contains('→'));
    final response = logger.entries.firstWhere((e) => e.tag.contains('←'));
    expect(request.line, contains('eth_getBalance'));
    expect(request.line, contains('node.example/rpc'));
    expect(response.line, contains('200'));
    expect(response.line, contains('0x1'));
  });

  test('truncates long bodies to maxBodyLength', () async {
    final logger = _CapturingLogger();
    final inner = MockClient((_) async => http.Response('ok', 200));
    final client = LoggingHttpClient(inner, logger: logger, maxBodyLength: 10);

    await client.post(uri, body: 'x' * 100);

    final request = logger.entries.firstWhere((e) => e.tag.contains('→'));
    expect(request.line, contains('xxxxxxxxxx…(100)'));
    expect(request.line, isNot(contains('x' * 11)));
  });

  test('logs and rethrows on transport error', () async {
    final logger = _CapturingLogger();
    final inner = MockClient((_) async => throw const _Boom());
    final client = LoggingHttpClient(inner, logger: logger);

    await expectLater(
      client.post(uri, body: '{}'),
      throwsA(isA<_Boom>()),
    );
    expect(logger.entries.any((e) => e.tag.contains('✕')), isTrue);
  });
}

class _Boom implements Exception {
  const _Boom();
}
