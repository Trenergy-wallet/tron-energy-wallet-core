import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _url = 'https://node.example/blockbook';
const _address = 'ltc1qjmxnz78nmc8nq77wuxh25n2es7rzm5c2rkk4wh';
final String _txId = 'bb' * 32;

/// Blockbook `/api/v2/tx/<txid>` of an unconfirmed RBF transaction
Map<String, dynamic> _txJson() => {
  'txid': _txId,
  'vin': [
    {
      'txid': 'aa' * 32,
      'sequence': 4294967293,
      'n': 0,
      'addresses': [_address],
      'isAddress': true,
      'value': '100000',
    },
  ],
  'vout': [
    {
      'value': '99000',
      'n': 0,
      'hex': '0014',
      'addresses': [_address],
      'isAddress': true,
    },
  ],
  'blockHeight': -1,
  'confirmations': 0,
  'rbf': true,
  'fees': '1000',
  'size': 222,
  'vsize': 141,
};

BlockbookNodeRepo _repo(
  FutureOr<http.Response> Function(http.Request request) handler, {
  Duration requestTimeout = CoreConsts.defaultRequestTimeout,
}) => BlockbookNodeRepo(
  rpc: BlockbookProvider(
    BlockbookHTTPProvider(
      url: _url,
      client: MockClient((request) async => handler(request)),
      requestTimeout: requestTimeout,
    ),
  ),
);

http.Response _json(Object body, [int statusCode = 200]) =>
    http.Response(jsonEncode(body), statusCode);

/// The exception of [future]: the repo throws only [AppExceptionWithCode]
Future<AppExceptionWithCode> _thrown(Future<Object?> future) async {
  try {
    await future;
  } on AppExceptionWithCode catch (e) {
    return e;
  }
  fail('AppExceptionWithCode expected');
}

void main() {
  group('fetchUtxosV1', () {
    test('requests api v1, parses satoshis', () async {
      late Uri url;
      final repo = _repo((request) {
        url = request.url;
        return _json([
          {'txid': _txId, 'vout': 1, 'satoshis': 2000, 'confirmations': 0},
        ]);
      });

      final utxos = await repo.fetchUtxosV1(address: _address);

      expect(url.toString(), '$_url/api/v1/utxo/$_address');
      expect(utxos.single.txid, _txId);
      expect(utxos.single.vout, 1);
      expect(utxos.single.value, BigInt.from(2000));
      expect(utxos.single.confirmations, 0);
      expect(utxos.single.height, CoreConsts.invalidIntValue);
    });

    test('confirmed goes to the query', () async {
      late Uri url;
      final repo = _repo((request) {
        url = request.url;
        return _json(<Object>[]);
      });

      final utxos = await repo.fetchUtxosV1(
        address: _address,
        confirmed: false,
      );

      expect(url.toString(), '$_url/api/v1/utxo/$_address?confirmed=false');
      expect(utxos, isEmpty);
    });
  });

  group('fetchUtxosV2', () {
    test('requests api v2, parses the string value', () async {
      late Uri url;
      final repo = _repo((request) {
        url = request.url;
        return _json([
          {
            'txid': _txId,
            'vout': 0,
            'value': '123456789012',
            'height': 900608,
            'confirmations': 12,
          },
        ]);
      });

      final utxos = await repo.fetchUtxosV2(address: _address, confirmed: true);

      expect(url.toString(), '$_url/api/v2/utxo/$_address?confirmed=true');
      expect(utxos.single.value, BigInt.parse('123456789012'));
      expect(utxos.single.height, 900608);
      expect(utxos.single.confirmations, 12);
    });

    test('no UTXOs - an empty list', () async {
      final repo = _repo((_) => _json(<Object>[]));

      expect(await repo.fetchUtxosV2(address: _address), isEmpty);
    });
  });

  group('fetchTransaction', () {
    test('requests api v2, parses the transaction', () async {
      late Uri url;
      final repo = _repo((request) {
        url = request.url;
        return _json(_txJson());
      });

      final tx = await repo.fetchTransaction(txId: _txId);

      expect(url.toString(), '$_url/api/v2/tx/$_txId');
      expect(tx.txId, _txId);
      expect(tx.rbf, isTrue);
      expect(tx.fees, 1000);
      expect(tx.vSize, 141);
      expect(tx.vin.single.sequence, 4294967293);
      expect(tx.vout.single.valueInSatoshi, 99000);
    });
  });

  test('a transaction id of the node can not lead to another path', () async {
    late Uri url;
    final repo = _repo((request) {
      url = request.url;
      return _json(_txJson());
    });

    await repo.fetchTransaction(txId: '../../../../../account?x=1');

    expect(url.path, startsWith('/blockbook/api/v2/tx/'));
    expect(url.pathSegments.last, '../../../../../account?x=1');
    expect(url.hasQuery, isFalse);
  });

  group('THROWS', () {
    test('rpcError with the status and the reason of a node error', () async {
      final repo = _repo((_) => _json({'error': 'Invalid address'}, 400));

      final error = await _thrown(repo.fetchUtxosV2(address: 'wrong'));

      expect(error, isA<AppRpcException>());
      expect(error.code, ExceptionCode.rpcError);
      expect(error.message, contains('/api/v2/utxo/wrong'));
      expect(error.message, contains('400'));
      expect(error.message, contains('Invalid address'));
    });

    for (final statusCode in [401, 498, 500]) {
      test('rpcError on $statusCode', () async {
        final repo = _repo((_) => http.Response('nope', statusCode));

        final error = await _thrown(repo.fetchTransaction(txId: _txId));

        expect(error.code, ExceptionCode.rpcError);
        expect(error.message, contains('$statusCode'));
      });
    }

    test('connectionTimeout when the response is late', () async {
      final repo = _repo(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return _json(<Object>[]);
        },
        requestTimeout: const Duration(milliseconds: 10),
      );

      final error = await _thrown(repo.fetchUtxosV1(address: _address));

      expect(error.code, ExceptionCode.connectionTimeout);
    });

    test('connectionTimeout when the connection fails', () async {
      final repo = _repo((_) => throw http.ClientException('down'));

      final error = await _thrown(repo.fetchUtxosV2(address: _address));

      expect(error.code, ExceptionCode.connectionTimeout);
      expect(error.message, contains('down'));
    });

    test('an AppExceptionWithCode of the client is kept as is', () async {
      final thrown = AppException(
        code: ExceptionCode.unableToCreateTransaction,
      );
      final repo = _repo((_) => throw thrown);

      final error = await _thrown(repo.fetchTransaction(txId: _txId));

      expect(error, same(thrown));
    });

    test(
      'checkedFromJsonException when a field of the model is missing',
      () async {
        final repo = _repo((_) => _json(_txJson()..remove('fees')));

        final error = await _thrown(repo.fetchTransaction(txId: _txId));

        expect(error.code, ExceptionCode.checkedFromJsonException);
        expect(error.message, contains('/api/v2/tx/$_txId'));
      },
    );

    test(
      'checkedFromJsonException when a nested field is missing',
      () async {
        final json = _txJson();
        (json['vout'] as List).cast<Map<String, dynamic>>().single.remove(
          'hex',
        );
        final repo = _repo((_) => _json(json));

        final error = await _thrown(repo.fetchTransaction(txId: _txId));

        expect(error.code, ExceptionCode.checkedFromJsonException);
      },
    );

    test('checkedFromJsonException on a response of another shape', () async {
      final repo = _repo((_) => _json({'unexpected': true}));

      final error = await _thrown(repo.fetchUtxosV2(address: _address));

      expect(error.code, ExceptionCode.checkedFromJsonException);
    });

    test('checkedFromJsonException on a non JSON response', () async {
      final repo = _repo((_) => http.Response('<html>', 200));

      final error = await _thrown(repo.fetchUtxosV2(address: _address));

      expect(error.code, ExceptionCode.checkedFromJsonException);
    });

    test('checkedFromJsonException when a number is malformed', () async {
      final repo = _repo((_) => _json(_txJson()..['fees'] = 'abc'));

      final error = await _thrown(repo.fetchTransaction(txId: _txId));

      expect(error.code, ExceptionCode.checkedFromJsonException);
    });

    test('checkedFromJsonException when a UTXO value is malformed', () async {
      final repo = _repo(
        (_) => _json([
          {'txid': _txId, 'vout': 0, 'value': 'abc', 'confirmations': 1},
        ]),
      );

      final error = await _thrown(repo.fetchUtxosV2(address: _address));

      expect(error.code, ExceptionCode.checkedFromJsonException);
    });
  });
}
