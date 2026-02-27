import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tr_ton_wallet_service/tr_ton_wallet_service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

// Explorer: https://testnet.tonscan.org

final tonRpc = TonProvider(
  TonHTTPProvider(
    tonApiUrl: 'https://testnet.tonapi.io',
    tonCenterUrl: 'https://testnet.toncenter.com',
    tonApiKey: 'your api key',
  ),
);

Future<void> main() async {
  final logger = InAppLogger()..usePrint = true;
  final service = TransactionsServiceTonImpl(
    currentAccountWallet: () => null,
    isTestnet: true,
    tonProvider: tonRpc,
    logger: logger,
    getSigningKey: (_) async => 'mnemonic',
  );

  final walletInfo = await service.initializeWalletAndGetInfo(
    masterKey: '',
  );
  logger.logInfoMessage('tonExample', 'Address: ${walletInfo.address}');

  final tx = await service.createTransaction(
    params: TransferParamsTON(
      to: 'Uf_a4Onq2UrxzOsJWYrKWohBfVsv-cW1Gd6yTQmQF2b84L8C',
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.05'),
      tokenWalletType: TokenWalletType.master,
      // message: '',
    ),
    masterKey: '',
  );
  logger.logInfoMessage('tonExample', 'TX: $tx');
  final res = await tonRpc.request(TonCenterSendBocReturnHash(tx));
  // Also:
  // final res = await tonProvider.request(
  //   TonApiSendBlockchainMessage(batch: [], boc: tx),
  // );
  final sentTx = res['hash'].toString();
  logger.logInfoMessage('tonExample', 'SENT: $sentTx');
}
