import 'dart:convert';

import 'package:on_chain/tron/src/models/contract/transaction/transaction.dart'
    show Transaction;
import 'package:on_chain/tron/src/provider/methods/broadcast_hex.dart'
    show TronRequestBroadcastHex;
import 'package:on_chain/tron/src/provider/provider/provider.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../../common/setup_account.dart';
import '../../data/repo/local_repo_core_impl.dart';
import 'domain/asset.dart';

final tronRpc = TronProvider(
  TronHTTPProvider(
    url: 'https://nile.trongrid.io',
    authToken: 'your-api-key',
  ),
);

Future<void> main() async {
  final tronAddress = await setupAccount(
    mnemonic: 'test mnemonic',
  );
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();
  // Lots of TRON examples can be found here: https://github.com/mrtnetwork/On_chain/blob/main/example/lib/example
  final tronService = TransactionsServiceTronImpl(
    localRepo: localRepo,
    postTransaction: postTransactionTron,
    tronProvider: tronRpc,
  );

  final tronAsset = tronAssetExample(tronAddress);

  final tx = await tronService.createTransactionOrThrow(
    toAddress: 'TP8KmXDvKVYg5WVTTyqaNT61Htguw2NJBs',
    amount: 1,
    asset: tronAsset,
    masterKey: '',
    message: 'hello example',
  );
  logger.logInfoMessage('tronExample', 'TX: $tx');
  final sentTx = await tronService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('tronExample', 'SENT: $sentTx');
}

Future<Either<AppExceptionWithCode, TransactionInfoData>> postTransactionTron({
  required AppBlockchain appBlockchain,
  required String tx,
  String? txFee,
}) async {
  try {
    final decoded = json.decode(tx) as Map<String, dynamic>;
    final transaction = Transaction.fromJson(decoded);
    final res = await tronRpc.request(
      TronRequestBroadcastHex(transaction: transaction.toHex),
    );

    return Right(
      TransactionInfoData(
        txId: res.txid,
        linkToBlockchain: 'https://nile.tronscan.org/#/transaction/${res.txid}',
      ),
    );
  } on Exception catch (e) {
    return Left(AppException(message: e.toString()));
  }
}
