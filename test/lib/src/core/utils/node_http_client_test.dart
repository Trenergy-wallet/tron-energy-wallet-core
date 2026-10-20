import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/core/utils/node_http_client.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Records requests and closing, fails after close like a real client
class _RecordingClient extends http.BaseClient {
  final requests = <http.BaseRequest>[];
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (closed) throw http.ClientException('Client is already closed');
    requests.add(request);
    return http.StreamedResponse(
      Stream.value('{"jsonrpc":"2.0","id":1,"result":"0x2a"}'.codeUnits),
      200,
    );
  }

  @override
  void close() => closed = true;
}

void main() {
  final logger = InAppLogger();

  group('nodeHttpClient', () {
    test('nothing set - null, the provider creates its own client', () {
      expect(nodeHttpClient(), isNull);
    });

    test('client without logger - the client as is', () {
      final client = MockClient((_) async => http.Response('', 200));
      expect(nodeHttpClient(client: client), same(client));
    });

    test('logger - wraps into LoggingHttpClient, with or without client', () {
      expect(nodeHttpClient(logger: logger), isA<LoggingHttpClient>());
      expect(
        nodeHttpClient(client: _RecordingClient(), logger: logger),
        isA<LoggingHttpClient>(),
      );
    });

    test('the logging wrapper sends through the passed client', () async {
      final client = _RecordingClient();
      await nodeHttpClient(
        client: client,
        logger: logger,
      )!.get(Uri.parse('https://api.example.com/x'));
      expect(client.requests, hasLength(1));
    });
  });

  group('UnclosableHttpClient', () {
    test('forwards requests', () async {
      final inner = _RecordingClient();
      await UnclosableHttpClient(inner).get(Uri.parse('https://a.example/x'));
      expect(inner.requests, hasLength(1));
    });

    test('close does not close the wrapped client', () async {
      final inner = _RecordingClient();
      UnclosableHttpClient(inner).close();
      // Also through a logging wrapper: LoggingHttpClient closes its inner
      LoggingHttpClient(UnclosableHttpClient(inner), logger: logger).close();
      expect(inner.closed, isFalse);
      await inner.get(Uri.parse('https://a.example/x'));
    });
  });

  group('network services use the passed client', () {
    TransactionsServiceEthereumImpl ethereum(
      http.Client client, {
      TRLogger? logger,
    }) => TransactionsServiceEthereumImpl(
      appBlockchain: AppBlockchain.ethereum,
      getSigningKey: (_) async => '',
      apiUri: 'https://api.example.com/eth',
      getAuthToken: () => '15|token',
      httpClient: client,
      logger: logger,
    );

    test('Ethereum: node requests go through the client', () async {
      final client = _RecordingClient();
      expect(await ethereum(client).tryGetGasPrice(), BigInt.from(42));
      final request = client.requests.single;
      expect(request.url.toString(), 'https://api.example.com/eth');
      expect(request.headers['Authorization'], 'Bearer 15|token');
    });

    test('Ethereum with a logger: still through the client', () async {
      final client = _RecordingClient();
      await ethereum(client, logger: logger).tryGetGasPrice();
      expect(client.requests, hasLength(1));
    });

    test('Base takes the client too', () async {
      final client = _RecordingClient();
      final base = TransactionsServiceBaseImpl(
        getSigningKey: (_) async => '',
        apiUri: 'https://api.example.com/base',
        httpClient: client,
      );
      await base.tryGetGasPrice();
      expect(client.requests.single.url.path, '/base');
    });

    test('Optimism takes the client too', () async {
      final client = _RecordingClient();
      final optimism = TransactionsServiceOptimismImpl(
        getSigningKey: (_) async => '',
        apiUri: 'https://api.example.com/op',
        httpClient: client,
      );
      await optimism.tryGetGasPrice();
      expect(client.requests.single.url.path, '/op');
    });
  });
}
