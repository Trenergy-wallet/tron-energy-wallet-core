import 'dart:async';

import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:on_chain/on_chain.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _url = 'https://node.example/sol';

/// Node mock: answers every JSON-RPC call with 42, records the requests
MockClient _node(List<http.Request> requests) => MockClient((request) async {
  requests.add(request);
  return http.Response('{"jsonrpc":"2.0","id":1,"result":42}', 200);
});

SolanaProvider _rpc({
  required http.Client client,
  String? Function()? getAuthToken,
}) => SolanaProvider(
  SolanaHTTPProvider(url: _url, client: client, getAuthToken: getAuthToken),
);

SolanaRequestGetMinimumBalanceForRentExemption get _request =>
    const SolanaRequestGetMinimumBalanceForRentExemption(size: 0);

void main() {
  group('auth token', () {
    test('is read on every request, a new token is picked up', () async {
      final requests = <http.Request>[];
      var token = 'first';
      final rpc = _rpc(client: _node(requests), getAuthToken: () => token);

      await rpc.request(_request);
      token = 'second';
      await rpc.request(_request);

      expect(requests[0].headers['Authorization'], 'Bearer first');
      expect(requests[1].headers['Authorization'], 'Bearer second');
    });

    for (final (name, getAuthToken) in [
      ('no callback', null),
      ('callback returns null', () => null),
      ('callback returns an empty string', () => ''),
    ]) {
      test('no Authorization header: $name', () async {
        final requests = <http.Request>[];
        final rpc = _rpc(client: _node(requests), getAuthToken: getAuthToken);

        await rpc.request(_request);

        expect(requests.single.headers.containsKey('Authorization'), isFalse);
      });
    }

    test('request headers win over the token', () async {
      final requests = <http.Request>[];
      final provider = SolanaHTTPProvider(
        url: _url,
        client: _node(requests),
        getAuthToken: () => 'token',
      );

      await provider.doRequest(
        const SolanaRequestDetails(
          requestID: 1,
          responseEncoding: ServiceReponseEncoding.json,
          headers: {'Authorization': 'Bearer own'},
          method: 'getMinimumBalanceForRentExemption',
        ),
      );

      expect(requests.single.headers['Authorization'], 'Bearer own');
    });
  });

  test('POST to the url through the one injected client', () async {
    final requests = <http.Request>[];
    final rpc = _rpc(client: _node(requests));

    final res = await rpc.request(_request);
    await rpc.request(_request);

    expect(res, BigInt.from(42));
    expect(requests, hasLength(2));
    expect(requests.first.method, 'POST');
    expect(requests.first.url.toString(), _url);
  });

  group('THROWS', () {
    test('TimeoutException when the response is late', () async {
      final provider = SolanaHTTPProvider(
        url: _url,
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return http.Response('{}', 200);
        }),
        requestTimeout: const Duration(milliseconds: 10),
      );

      await expectLater(
        SolanaProvider(provider).request(_request),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('ClientException from the client is passed through', () async {
      final rpc = _rpc(
        client: MockClient((_) async => throw http.ClientException('down')),
      );

      await expectLater(
        rpc.request(_request),
        throwsA(isA<http.ClientException>()),
      );
    });
  });
}
