import 'package:blockchain_utils/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:on_chain/on_chain.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Node mock: answers every JSON-RPC call with 0x2a, records the requests
MockClient _node(List<http.Request> requests) => MockClient((request) async {
  requests.add(request);
  return http.Response('{"jsonrpc":"2.0","id":1,"result":"0x2a"}', 200);
});

EthereumProvider _rpc(
  String url, {
  http.Client? client,
  String? Function()? getAuthToken,
}) => EthereumProvider(
  EthereumHTTPProvider(url, client: client, getAuthToken: getAuthToken),
);

void main() {
  group('node requests go through the injected provider', () {
    test('Ethereum: the token is read on every request', () async {
      final requests = <http.Request>[];
      var token = 'first';
      final service = TransactionsServiceEthereumImpl(
        appBlockchain: AppBlockchain.ethereum,
        getSigningKey: (_) async => '',
        rpc: _rpc(
          'https://api.example.com/eth',
          client: _node(requests),
          getAuthToken: () => token,
        ),
      );

      expect(await service.tryGetGasPrice(), BigInt.from(42));
      token = 'second';
      await service.tryGetGasPrice();

      expect(requests, hasLength(2));
      expect(requests[0].url.toString(), 'https://api.example.com/eth');
      expect(requests[0].headers['Authorization'], 'Bearer first');
      expect(requests[1].headers['Authorization'], 'Bearer second');
    });

    test('Base', () async {
      final requests = <http.Request>[];
      final base = TransactionsServiceBaseImpl(
        getSigningKey: (_) async => '',
        rpc: _rpc('https://api.example.com/base', client: _node(requests)),
      );

      await base.tryGetGasPrice();

      expect(requests.single.url.path, '/base');
    });

    test('Optimism', () async {
      final requests = <http.Request>[];
      final optimism = TransactionsServiceOptimismImpl(
        getSigningKey: (_) async => '',
        rpc: _rpc('https://api.example.com/op', client: _node(requests)),
      );

      await optimism.tryGetGasPrice();

      expect(requests.single.url.path, '/op');
    });
  });

  group('TransactionsServiceEthereumImpl gasfree guard', () {
    final service = TransactionsServiceEthereumImpl(
      appBlockchain: AppBlockchain.ethereum,
      getSigningKey: (_) async => '',
      rpc: _rpc('http://localhost:8545'),
    );

    final eip1559Fee = FeeHistorical(
      slow: BigInt.one,
      normal: BigInt.one,
      high: BigInt.one,
      baseFee: BigInt.one,
    );

    TransferParamsETH params({required TokenWalletType tokenWalletType}) =>
        TransferParamsETH(
          to: '0x57Be4787b25ed040b69677B57D7Db565e174Aa97',
          from: '0x9858EfFD232B4033E47d90003D41EC34EcaEda94',
          amount: BigRational.one,
          chainId: 1,
          supportsEIP1559: true,
          tokenDecimal: 18,
          tokenWalletType: tokenWalletType,
          feeType: FeeType.gasFree,
          tokenContractAddress: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
        );

    test(
      'THROWS unableToCreateTransaction for gasfree in buildTransaction',
      () async {
        await expectLater(
          service.buildTransaction(
            params: params(tokenWalletType: TokenWalletType.master),
            nonce: 0,
            eip1559Fee: eip1559Fee,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.unableToCreateTransaction,
            ),
          ),
        );
      },
    );

    test(
      'THROWS unableToCreateTransaction for gasfree in buildERC20Transaction',
      () async {
        await expectLater(
          service.buildERC20Transaction(
            params: params(tokenWalletType: TokenWalletType.child),
            nonce: 0,
            eip1559Fee: eip1559Fee,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.unableToCreateTransaction,
            ),
          ),
        );
      },
    );
  });
}
