import 'dart:async';

import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:on_chain/on_chain.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _url = 'https://node.example/trx';

/// Node mock: answers getnowblock with an empty object, records the requests
MockClient _node(List<http.Request> requests) => MockClient((request) async {
  requests.add(request);
  return http.Response('{}', 200);
});

TronProvider _rpc({
  required http.Client client,
  String? Function()? getAuthToken,
}) => TronProvider(
  TronHTTPProvider(url: _url, client: client, getAuthToken: getAuthToken),
);

void main() {
  group('auth token', () {
    test('is read on every request, a new token is picked up', () async {
      final requests = <http.Request>[];
      var token = 'first';
      final rpc = _rpc(client: _node(requests), getAuthToken: () => token);

      await rpc.requestDynamic(TronRequestGetNowBlock());
      token = 'second';
      await rpc.requestDynamic(TronRequestGetNowBlock());

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

        await rpc.requestDynamic(TronRequestGetNowBlock());

        expect(requests.single.headers.containsKey('Authorization'), isFalse);
      });
    }

    test('request headers win over the token', () async {
      final requests = <http.Request>[];
      final provider = TronHTTPProvider(
        url: _url,
        client: _node(requests),
        getAuthToken: () => 'token',
      );

      await provider.doRequest(
        const TronRequestDetails(
          requestID: 1,
          responseEncoding: ServiceReponseEncoding.json,
          headers: {'Authorization': 'Bearer own'},
          method: 'wallet/getnowblock',
          requestMethod: RequestMethod.post,
        ),
      );

      expect(requests.single.headers['Authorization'], 'Bearer own');
    });
  });

  test('requests go to the url through the one injected client', () async {
    final requests = <http.Request>[];
    final rpc = _rpc(client: _node(requests));

    await rpc.requestDynamic(TronRequestGetNowBlock());
    await rpc.requestDynamic(TronRequestGetNowBlock());

    expect(requests, hasLength(2));
    expect(requests.first.url.toString(), startsWith(_url));
  });

  group('THROWS', () {
    test('TimeoutException when the response is late', () async {
      final provider = TronHTTPProvider(
        url: _url,
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return http.Response('{}', 200);
        }),
        requestTimeout: const Duration(milliseconds: 10),
      );

      await expectLater(
        TronProvider(provider).requestDynamic(TronRequestGetNowBlock()),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('ClientException from the client is passed through', () async {
      final rpc = _rpc(
        client: MockClient((_) async => throw http.ClientException('down')),
      );

      await expectLater(
        rpc.requestDynamic(TronRequestGetNowBlock()),
        throwsA(isA<http.ClientException>()),
      );
    });
  });
}
