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

/// Records the ids the provider builds the request with
class _RecordingRequest
    extends BlockbookRequest<Object?, Map<String, dynamic>> {
  final ids = <int>[];

  @override
  String get path => '/api/v2/estimatefee/2';

  @override
  BlockbookRequestDetails buildRequest(int requestID) {
    ids.add(requestID);
    return super.buildRequest(requestID);
  }
}

/// Own POST request with a body
class _SendTx extends BlockbookRequest<String, Map<String, dynamic>> {
  const _SendTx(this.rawTx);

  final String rawTx;

  @override
  String get path => '/api/v2/sendtx/';

  @override
  RequestMethod get requestMethod => RequestMethod.post;

  @override
  String get body => rawTx;

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

    test('every request gets the next id', () async {
      final rpc = _rpc((_) => http.Response('{"result":"0.0001"}', 200));
      final request = _RecordingRequest();

      await rpc.request(request);
      await rpc.requestDynamic(request);
      await rpc.request(request);

      expect(request.ids, [0, 1, 2]);
    });

    test('an own POST request sends its body', () async {
      late http.Request sent;
      final rpc = _rpc((request) {
        sent = request;
        return http.Response('{"result":"txid"}', 200);
      });

      expect(await rpc.request(const _SendTx('rawtx')), 'txid');
      expect(sent.method, 'POST');
      expect(sent.url.toString(), '$_url/api/v2/sendtx/');
      expect(sent.body, 'rawtx');
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

    test('is serialized to CBOR with its own tag', () {
      final cbor = details.toCbor();

      expect(cbor.encode(), isNotEmpty);
      expect(cbor.tags, [21007]);
      // Not the tag of the bitcoin_base requests: the fields differ
      expect(
        cbor.tags,
        isNot(contains(BlockchainNetwork.bitcoinAndRelated.identifier.id)),
      );
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

    for (final (name, value) in [
      ('path traversal', '../../../../../account'),
      ('query', 'aa?x=1'),
      ('fragment', 'aa#x'),
      ('slash', 'aa/bb'),
      ('space', 'aa bb'),
    ]) {
      test('a value from outside can not change the url: $name', () {
        for (final request in <BlockbookRequest<dynamic, dynamic>>[
          BlockbookRequestTransaction(txId: value),
          BlockbookRequestUtxosV1(address: value),
          BlockbookRequestUtxosV2(address: value, confirmed: true),
        ]) {
          final uri = request.buildRequest(0).encodeUrl(_url);
          final prefix = request.path.substring(
            0,
            request.path.lastIndexOf('/') + 1,
          );

          // The value stays one path segment after the path of the request
          expect(uri.path, startsWith('/blockbook$prefix'));
          expect(uri.pathSegments.last, value);
          expect(uri.hasFragment, isFalse);
          expect(
            uri.queryParameters,
            request is BlockbookRequestUtxosV2
                ? {'confirmed': 'true'}
                : isEmpty,
          );
        }
      });
    }

    test('a valid transaction id and address go as is', () {
      final txId = 'ab' * 32;

      expect(
        BlockbookRequestTransaction(txId: txId).buildRequest(0).path,
        '/api/v2/tx/$txId',
      );
      for (final address in [
        _address,
        'bc1p5d7rjq7g6rdk2yhzks9smlaqtedr4dekq08ge8ztwac72sfr9rusxg3297',
        '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
        'tltc1qjmxnz78nmc8nq77wuxh25n2es7rzm5c2rkk4wh',
      ]) {
        expect(
          BlockbookRequestUtxosV2(address: address).buildRequest(0).path,
          '/api/v2/utxo/$address',
        );
      }
    });

    test('the path is the same with and without the query', () {
      const value = 'a b/c';

      expect(
        const BlockbookRequestUtxosV1(
          address: value,
          confirmed: true,
        ).buildRequest(0).path,
        '${const BlockbookRequestUtxosV1(address: value).buildRequest(0).path}'
        '?confirmed=true',
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
