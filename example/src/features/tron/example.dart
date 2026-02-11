import 'dart:convert';

import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/tron/src/models/contract/transaction/transaction.dart'
    show Transaction;
import 'package:on_chain/tron/src/provider/methods/broadcast_hex.dart'
    show TronRequestBroadcastHex;
import 'package:on_chain/tron/src/provider/provider/provider.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'domain/asset.dart';

final tronRpc = TronProvider(
  TronHTTPProvider(
    url: 'https://nile.trongrid.io',
    authToken: 'your-api-key',
  ),
);

Future<void> main() async {
  final privateKey = await KeyGenerator(
    mnemonic: 'test mnemonic',
  ).generateForTron();

  final tronAddress = privateKey.publicKey().toAddress().toString();
  final logger = InAppLogger()..usePrint = true;
  // Lots of TRON examples can be found here: https://github.com/mrtnetwork/On_chain/blob/main/example/lib/example
  final tronService = TransactionsServiceTronImpl(
    tronProvider: tronRpc,
    logger: logger,
    getSigningKey: (_) async => privateKey,
  );

  final tronAsset = tronAssetExample(tronAddress);

  final tx = await tronService.createTransaction(
    toAddress: 'TP8KmXDvKVYg5WVTTyqaNT61Htguw2NJBs',
    amount: BigRational.parseDecimal('1'),
    asset: tronAsset,
    masterKey: '',
    message: 'hello example',
  );
  logger.logInfoMessage('tronExample', 'TX: $tx');
  final sentTx = await _postTransactionTron(tx: tx);
  logger.logInfoMessage('tronExample', 'SENT: $sentTx');
}

Future<TransactionInfoData> _postTransactionTron({
  required String tx,
}) async {
  final decoded = json.decode(tx) as Map<String, dynamic>;
  final transaction = Transaction.fromJson(decoded);
  final res = await tronRpc.request(
    TronRequestBroadcastHex(transaction: transaction.toHex),
  );

  return TransactionInfoData(
    txId: res.txid,
    linkToBlockchain: 'https://nile.tronscan.org/#/transaction/${res.txid}',
  );
}
