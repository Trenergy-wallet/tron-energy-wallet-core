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

Future<Either<AppExceptionWithCode, TransactionInfoData>> postTransaction({
  required AppBlockchain appBlockchain,
  required String tx,
  String? txFee,
}) async {
  return Left(AppException(message: 'Not posted'));
}
