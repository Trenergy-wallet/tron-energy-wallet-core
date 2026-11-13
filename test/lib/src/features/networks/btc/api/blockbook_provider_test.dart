import 'dart:convert';

import 'package:blockchain_utils/blockchain_utils.dart'
    hide Either, Left, Right;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _url = 'https://node.example/blockbook';
const _address = 'ltc1qjmxnz78nmc8nq77wuxh25n2es7rzm5c2rkk4wh';

BlockbookProvider _rpc(http.Response Function(http.Request request) handler) =>
    BlockbookProvider(
      BlockbookHTTPProvider(
        url: _url,
        client: MockClient((request) async => handler(request)),
      ),
    );

/// Own request on top of the base: the caller can add the ones it needs
class _EstimateFee extends BlockbookRequest<String, Map<String, dynamic>> {
  const _EstimateFee();

  @override
  String get path => '/api/v2/estimatefee/2';

  @override
  String onResonse(Map<String, dynamic> result) => result['result'] as String;
}

void main() {
  group('BlockbookProvider', () {
    test('request converts the response with the request', () async {
      final rpc = _rpc(
        (_) => http.Response(
          jsonEncode([
            {'txid': 'aa', 'vout': 0, 'value': '10', 'confirmations': 1},
          ]),
          200,
        ),
      );

      final utxos = await rpc.request(
        const BlockbookRequestUtxosV2(address: _address),
      );

      expect(utxos.single.value, BigInt.from(10));
    });

    test('requestDynamic returns the response as is', () async {
      final rpc = _rpc((_) => http.Response('{"result":"0.0001"}', 200));

      final response = await rpc.requestDynamic(const _EstimateFee());

      expect(response, {'result': '0.0001'});
    });

    test('an own request goes to its path', () async {
      late Uri url;
      final rpc = _rpc((request) {
        url = request.url;
        return http.Response('{"result":"0.0001"}', 200);
      });

      expect(await rpc.request(const _EstimateFee()), '0.0001');
      expect(url.toString(), '$_url/api/v2/estimatefee/2');
    });

    test('request ids grow', () {
      const request = BlockbookRequestTransaction(txId: 'aa');

      expect(request.buildRequest(0).requestID, 0);
      expect(request.buildRequest(7).requestID, 7);
    });

    for (final statusCode in [400, 401, 498, 500]) {
      test('THROWS RPCError with the status on $statusCode', () async {
        final rpc = _rpc(
          (_) => http.Response('{"error":"Invalid address"}', statusCode),
        );

        await expectLater(
          rpc.request(const BlockbookRequestUtxosV2(address: _address)),
          throwsA(
            isA<RPCError>()
                .having((e) => e.statusCode, 'statusCode', statusCode)
                .having((e) => e.message, 'message', contains('Invalid')),
          ),
        );
      });
    }

    test('THROWS RPCError on a response of another shape', () async {
      final rpc = _rpc((_) => http.Response('{"unexpected":true}', 200));

      await expectLater(
        rpc.request(const BlockbookRequestUtxosV2(address: _address)),
        throwsA(isA<RPCError>()),
      );
    });

    test('THROWS RPCError on a non JSON response', () async {
      final rpc = _rpc((_) => http.Response('<html>', 200));

      await expectLater(
        rpc.request(const BlockbookRequestTransaction(txId: 'aa')),
        throwsA(isA<RPCError>()),
      );
    });
  });

  group('BlockbookRequestDetails', () {
    const details = BlockbookRequestDetails(
      requestID: 3,
      path: '/api/v2/utxo/$_address?confirmed=true',
      requestMethod: RequestMethod.get,
      responseEncoding: ServiceReponseEncoding.json,
    );

    test('encodeUrl appends the path to the root', () {
      const expected = '$_url/api/v2/utxo/$_address?confirmed=true';

      expect(details.encodeUrl(_url).toString(), expected);
      expect(details.encodeUrl('$_url/').toString(), expected);
    });

    test('toJson describes the request', () {
      expect(details.toJson(), {
        'requestId': 3,
        'type': 'get',
        'path': '/api/v2/utxo/$_address?confirmed=true',
        'body': null,
      });
    });

    test('is serialized to CBOR', () {
      expect(details.toCbor().encode(), isNotEmpty);
    });
  });

  group('requests', () {
    test('query is skipped when confirmed is not set', () {
      expect(
        const BlockbookRequestUtxosV1(address: _address).buildRequest(0).path,
        '/api/v1/utxo/$_address',
      );
    });

    test('confirmed goes to the query', () {
      expect(
        const BlockbookRequestUtxosV2(
          address: _address,
          confirmed: false,
        ).buildRequest(0).path,
        '/api/v2/utxo/$_address?confirmed=false',
      );
    });

    test('requests are GET', () {
      expect(
        const BlockbookRequestTransaction(
          txId: 'aa',
        ).buildRequest(0).requestMethod,
        RequestMethod.get,
      );
    });
  });
}
