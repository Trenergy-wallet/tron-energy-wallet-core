import 'dart:convert';

import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

AppAsset tronAssetExample(String address) => AppAsset(
  id: 710,
  balance: 5900.13,
  token: const AppToken(
    id: 2,
    name: 'TRX',
    shortName: 'TRON',
    icon: 'https://static.tronscan.org/production/logo/trx.png',
    usdPrice: 0.350538,
    prevPriceDiffPercent: 0.08,
    contractAddress: '',
    decimal: 6,
    blockchain: BlockchainInfo(
      id: 1,
      name: 'Tron',
      shortName: 'TRON',
      icon: 'https://static.tronscan.org/production/logo/trx.png',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.tron,
    ),
    tokenWalletType: TokenWalletType.master,
    description: 'Official Token of TRON Protocol',
    precision: 2,
  ),
  address: address,
  walletId: 171,
  childWalletAddress: '',
);

Future<Either<AppExceptionWithCode, TransactionInfoData>> postTransactionTron({
  required AppBlockchain appBlockchain,
  required String tx,
  String? txFee,
}) async {
  try {
    final tronProvider = TronProvider(
      TronHTTPProvider(
        url: 'https://nile.trongrid.io',
        authToken: 'your-token',
      ),
    );
    // A bit complicated, first, we have to remove some data, which is
    // included in [tx] and is necessary for tronEnergy use purposes
    final decodedTxJson = jsonDecode(tx) as Map<String, dynamic>;
    final rawData = TransactionRaw.fromJson(
      decodedTxJson['raw_data'] as Map<String, dynamic>,
    );
    final signatures = (decodedTxJson['signature'] as List<dynamic>)
        .map((e) => BytesUtils.fromHexString(e.toString()))
        .toList();
    final purifiedTx = Transaction(rawData: rawData, signature: signatures);
    final res = await tronProvider.request(
      TronRequestBroadcastHex(
        transaction: BytesUtils.toHexString(purifiedTx.toBuffer()),
      ),
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
