import 'dart:async';

import 'package:blockchain_utils/service/models/params.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _url = 'https://node.example/blockbook';
const _address = 'ltc1qjmxnz78nmc8nq77wuxh25n2es7rzm5c2rkk4wh';
const _request = BlockbookRequestUtxosV2(address: _address);

/// Node mock: answers with an empty UTXO list, records the requests
MockClient _node(List<http.Request> requests) => MockClient((request) async {
  requests.add(request);
  return http.Response('[]', 200);
});

BlockbookProvider _rpc({
  required http.Client client,
  String? Function()? getAuthorization,
}) => BlockbookProvider(
  BlockbookHTTPProvider(
    url: _url,
    client: client,
    getAuthorization: getAuthorization,
  ),
);

void main() {
  group('Authorization', () {
    test('is read on every request, a new value is picked up', () async {
      final requests = <http.Request>[];
      var authorization = 'Bearer first';
      final rpc = _rpc(
        client: _node(requests),
        getAuthorization: () => authorization,
      );

      await rpc.request(_request);
      authorization = 'DPoP second';
      await rpc.request(_request);

      expect(requests[0].headers['Authorization'], 'Bearer first');
      // The scheme is not added: the header goes as is
      expect(requests[1].headers['Authorization'], 'DPoP second');
    });

    for (final (name, getAuthorization) in [
      ('no callback', null),
      ('callback returns null', () => null),
      ('callback returns an empty string', () => ''),
    ]) {
      test('no Authorization header: $name', () async {
        final requests = <http.Request>[];
        final rpc = _rpc(
          client: _node(requests),
          getAuthorization: getAuthorization,
        );

        await rpc.request(_request);

        expect(requests.single.headers.containsKey('Authorization'), isFalse);
      });
    }

    test('request headers win over getAuthorization', () async {
      final requests = <http.Request>[];
      final provider = BlockbookHTTPProvider(
        url: _url,
        client: _node(requests),
        getAuthorization: () => 'Bearer token',
      );

      await provider.doRequest(
        const BlockbookRequestDetails(
          requestID: 1,
          responseEncoding: ServiceReponseEncoding.json,
          headers: {'Authorization': 'Bearer own'},
          path: '/api/v2/utxo',
          requestMethod: RequestMethod.get,
        ),
      );

      expect(requests.single.headers['Authorization'], 'Bearer own');
    });
  });

  test('requests go to the url through the one injected client', () async {
    final requests = <http.Request>[];
    final rpc = _rpc(client: _node(requests));

    await rpc.request(_request);
    await rpc.request(_request);

    expect(requests, hasLength(2));
    expect(requests.first.method, 'GET');
    expect(requests.first.url.toString(), '$_url/api/v2/utxo/$_address');
  });

  test('a trailing slash of the url is not doubled', () async {
    final requests = <http.Request>[];
    final rpc = BlockbookProvider(
      BlockbookHTTPProvider(url: '$_url/', client: _node(requests)),
    );

    await rpc.request(_request);

    expect(requests.single.url.toString(), '$_url/api/v2/utxo/$_address');
  });

  test('a POST request sends its body', () async {
    final requests = <http.Request>[];
    final provider = BlockbookHTTPProvider(url: _url, client: _node(requests));

    await provider.doRequest(
      const BlockbookRequestDetails(
        requestID: 1,
        responseEncoding: ServiceReponseEncoding.json,
        path: '/api/v2/sendtx/',
        requestMethod: RequestMethod.post,
        bodyString: 'rawtx',
      ),
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.body, 'rawtx');
  });

  group('THROWS', () {
    test('TimeoutException when the response is late', () async {
      final provider = BlockbookHTTPProvider(
        url: _url,
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return http.Response('[]', 200);
        }),
        requestTimeout: const Duration(milliseconds: 10),
      );

      await expectLater(
        BlockbookProvider(provider).request(_request),
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
