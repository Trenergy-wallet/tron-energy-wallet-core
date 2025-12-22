import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tr_ton_wallet_service/tr_ton_wallet_service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../../common/setup_account.dart';
import '../../data/repo/local_repo_core_impl.dart';
import 'domain/asset.dart';

final tonRpc = TonProvider(
  TonHTTPProvider(
    tonApiUrl: 'https://testnet.tonapi.io',
    tonCenterUrl: 'https://testnet.toncenter.com',
    tonApiKey: 'your-api-key',
  ),
);

Future<void> main() async {
  await setupAccount(
    mnemonic: 'mnemonic',
  );
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();

  final tonService = TransactionsServiceTonImpl(
    localRepo: localRepo,
    postTransaction: postTransactionTon,
    currentAccountWallet: () => null,
    isTestnet: true,
    tonProvider: tonRpc,
  );

  final walletInfo = await tonService.tryInitializeWalletAndGetInfoOrThrow(
    masterKey: '',
  );
  logger.logInfoMessage('tonExample', 'Address: ${walletInfo.address}');

  final tonAsset = tonAssetExample(walletInfo.address);
  final tx = await tonService.createTransactionOrThrow(
    toAddress: 'Uf_a4Onq2UrxzOsJWYrKWohBfVsv-cW1Gd6yTQmQF2b84L8C',
    amount: BigRational.parseDecimal('0.05'),
    asset: tonAsset,
    masterKey: '',
  );
  logger.logInfoMessage('tonExample', 'TX: $tx');
  final sentTx = await tonService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('tonExample', 'SENT: $sentTx');
}

Future<Either<AppExceptionWithCode, TransactionInfoData>> postTransactionTon({
  required AppBlockchain appBlockchain,
  required String tx,
  String? txFee,
}) async {
  try {
    final res = await tonRpc.request(TonCenterSendBocReturnHash(tx));
    // Also:
    // final res = await tonProvider.request(
    //   TonApiSendBlockchainMessage(batch: [], boc: tx),
    // );
    final hash = res['hash'].toString();
    return Right(
      TransactionInfoData(
        txId: hash,
        linkToBlockchain: 'https://testnet.tonscan.org/tx/$hash',
      ),
    );
  } on Exception catch (e) {
    return Left(AppException(message: e.toString()));
  }
}
