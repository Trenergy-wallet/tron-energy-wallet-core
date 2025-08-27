import 'dart:convert';

import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:ton_wallet_service/ton_wallet_service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../example.dart' show tonApiKey;

AppAsset tronAssetExample(String address) => AppAsset(
  id: 27,
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

AppAsset tonAssetExample(String address) => AppAsset(
  id: 15,
  balance: 10,
  token: const AppToken(
    id: 534,
    name: 'TON',
    shortName: 'TON',
    icon:
        'https://s3.coinmarketcap.com/static/img/portraits/6304d4f7dcf54d0fb59743ba.png',
    usdPrice: 3.189150,
    prevPriceDiffPercent: -31.45,
    contractAddress: '',
    decimal: 9,
    blockchain: BlockchainInfo(
      id: 13,
      name: 'TON',
      shortName: 'TON',
      icon:
          'https://s3.coinmarketcap.com/static/img/portraits/6304d4f7dcf54d0fb59743ba.png',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.ton,
    ),
    tokenWalletType: TokenWalletType.master,
    description: '',
    precision: 2,
  ),
  address: address,
  walletId: 211,
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

Future<Either<AppExceptionWithCode, TransactionInfoData>> postTransactionTon({
  required AppBlockchain appBlockchain,
  required String tx,
  String? txFee,
}) async {
  try {
    final tonProvider = TonProvider(
      TonHTTPProvider(
        tonApiUrl: 'https://testnet.tonapi.io',
        tonCenterUrl: 'https://testnet.toncenter.com',
        tonApiKey: tonApiKey,
      ),
    );

    final res = await tonProvider.request(TonCenterSendBocReturnHash(tx));
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
