import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tr_ton_wallet_service/tr_ton_wallet_service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'domain/asset.dart';

final tonRpc = TonProvider(
  TonHTTPProvider(
    tonApiUrl: 'https://testnet.tonapi.io',
    tonCenterUrl: 'https://testnet.toncenter.com',
    tonApiKey: 'your api key',
  ),
);

Future<void> main() async {
  final logger = InAppLogger()..usePrint = true;
  final tonService = TransactionsServiceTonImpl(
    currentAccountWallet: () => null,
    isTestnet: true,
    tonProvider: tonRpc,
    logger: logger,
    getSigningKey: (_) async => 'mnemonic',
  );

  final walletInfo = await tonService.initializeWalletAndGetInfo(
    masterKey: '',
  );
  logger.logInfoMessage('tonExample', 'Address: ${walletInfo.address}');

  final tonAsset = tonAssetExample(walletInfo.address);
  final tx = await tonService.createTransaction(
    toAddress: 'Uf_a4Onq2UrxzOsJWYrKWohBfVsv-cW1Gd6yTQmQF2b84L8C',
    amount: BigRational.parseDecimal('0.05'),
    asset: tonAsset,
    masterKey: '',
  );
  logger.logInfoMessage('tonExample', 'TX: $tx');
  final sentTx = await _postTransactionTon(tx: tx);
  logger.logInfoMessage('tonExample', 'SENT: $sentTx');
}

Future<TransactionInfoData> _postTransactionTon({
  required String tx,
}) async {
  final res = await tonRpc.request(TonCenterSendBocReturnHash(tx));
  // Also:
  // final res = await tonProvider.request(
  //   TonApiSendBlockchainMessage(batch: [], boc: tx),
  // );
  final hash = res['hash'].toString();
  return TransactionInfoData(
    txId: hash,
    linkToBlockchain: 'https://testnet.tonscan.org/tx/$hash',
  );
}
