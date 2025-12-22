import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

AppAsset tronAssetExample(String address) => AppAsset(
  id: 27,
  balance: BigRational.parseDecimal('5900.13'),
  hold: BigRational.zero,
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
      chainId: 0xcd8690dc,
      networkId: 0xcd8690dc,
      supportsEIP1559: false,
    ),
    tokenWalletType: TokenWalletType.master,
    description: 'Official Token of TRON Protocol',
    precision: 2,
  ),
);
