import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

void main() {
  group('TransactionsServiceEthereumImpl gasfree guard', () {
    final service = TransactionsServiceEthereumImpl(
      appBlockchain: AppBlockchain.ethereum,
      getSigningKey: (_) async => '',
      apiUri: 'http://localhost:8545',
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
            rpc: EthereumProvider(
              EthereumHTTPProvider('http://localhost:8545', null),
            ),
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
            rpc: EthereumProvider(
              EthereumHTTPProvider('http://localhost:8545', null),
            ),
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
