import 'dart:convert';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _tonCenterUrl = 'https://toncenter.example';
const _address = 'UQAqbua3_0G_7K_jgzhjJceolfT-TONGsY65wUoBUtZinP1w';

/// TonCenter mock: answers getWalletInformation with [accountState]
MockClient _tonCenter(
  List<http.Request> requests, {
  String accountState = 'active',
}) => MockClient((request) async {
  requests.add(request);
  return http.Response(
    jsonEncode({
      'ok': true,
      'result': {'account_state': accountState},
    }),
    200,
  );
});

TransactionsServiceTonImpl _service({
  required http.Client client,
  String? Function()? getAuthToken,
  Future<String> Function(String masterKey)? getSigningKey,
}) {
  final provider = TonHTTPProvider(
    tonApiUrl: 'https://tonapi.example',
    tonCenterUrl: _tonCenterUrl,
    client: client,
    getAuthToken: getAuthToken,
  );
  return TransactionsServiceTonImpl(
    currentAccountWallet: () => null,
    getSigningKey: getSigningKey ?? (_) async => '',
    isTestnet: false,
    rpc: TonProvider(provider, provider.api),
  );
}

void main() {
  group('TransactionsServiceTonImpl', () {
    test('requests go through the injected provider, the token is read on '
        'every request', () async {
      final requests = <http.Request>[];
      var token = 'first';
      final service = _service(
        client: _tonCenter(requests),
        getAuthToken: () => token,
      );

      await service.checkWalletIsFrozen(
        assetAddress: _address,
        addressToCheck: _address,
      );
      token = 'second';
      await service.checkWalletIsFrozen(
        assetAddress: _address,
        addressToCheck: _address,
      );

      expect(requests, hasLength(2));
      expect(requests.first.url.origin, _tonCenterUrl);
      expect(requests[0].headers['Authorization'], 'Bearer first');
      expect(requests[1].headers['Authorization'], 'Bearer second');
    });

    group('checkWalletIsFrozen', () {
      test('true for a frozen wallet', () async {
        final service = _service(
          client: _tonCenter([], accountState: 'frozen'),
        );

        final res = await service.checkWalletIsFrozen(
          assetAddress: _address,
          addressToCheck: _address,
        );

        expect(res, isTrue);
      });

      test('false for an active wallet', () async {
        final service = _service(client: _tonCenter([]));

        final res = await service.checkWalletIsFrozen(
          assetAddress: _address,
          addressToCheck: _address,
        );

        expect(res, isFalse);
      });

      test('null when the node is unavailable', () async {
        final service = _service(
          client: MockClient((_) async => throw http.ClientException('down')),
        );

        final res = await service.checkWalletIsFrozen(
          assetAddress: _address,
          addressToCheck: _address,
        );

        expect(res, isNull);
      });
    });

    test('THROWS amountIsNotPositive for a zero amount', () async {
      final service = _service(client: _tonCenter([]));

      await expectLater(
        service.createTransaction(
          params: TransferParamsTON(
            to: _address,
            from: _address,
            amount: BigRational.zero,
            tokenWalletType: TokenWalletType.master,
          ),
          masterKey: 'mk',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.amountIsNotPositive,
          ),
        ),
      );
    });

    test('THROWS unableToRetrieveMnemonic for an empty mnemonic', () async {
      final service = _service(client: _tonCenter([]));

      await expectLater(
        service.initializeWalletAndGetInfo(masterKey: 'mk'),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.unableToRetrieveMnemonic,
          ),
        ),
      );
    });
  });
}
