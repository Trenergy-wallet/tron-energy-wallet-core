import 'dart:convert';

import 'package:on_chain/on_chain.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../example.dart' show tonRpc, tronRpc;

AppAsset tronAssetExample(String address) => AppAsset(
  id: 27,
  balance: 5900.13,
  address: address,
  walletId: 171,
  childWalletAddress: '',
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
);

AppAsset tonAssetExample(String address) => AppAsset(
  id: 15,
  balance: 10,
  address: address,
  walletId: 211,
  childWalletAddress: '',
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
);

AppAsset btcAssetExample(String address) => AppAsset(
  id: 125,
  balance: 1,
  address: address,
  walletId: 381,
  childWalletAddress: '',
  token: const AppToken(
    id: 32,
    name: 'Bitcoin',
    shortName: 'BTC',
    icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png',
    usdPrice: 3112870.997223,
    prevPriceDiffPercent: -0.03,
    contractAddress: '',
    decimal: 8,
    blockchain: BlockchainInfo(
      id: 19,
      name: 'Bitcoin',
      shortName: 'BTC',
      icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.bitcoin,
    ),
    tokenWalletType: TokenWalletType.master,
    description:
        'Bitcoin is a decentralized cryptocurrency originally described in a '
        '2008 whitepaper by a person, or group of people, using the alias '
        'Satoshi Nakamoto. It was launched soon after, in January 2009.',
    precision: 8,
  ),
);

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
