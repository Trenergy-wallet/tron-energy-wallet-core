import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

AppAsset bnbAssetExample({
  required String address,
}) => AppAsset(
  id: 884,
  balance: BigRational.one,
  hold: BigRational.zero,
  address: address,
  walletId: 4422,
  childWalletAddress: '',
  token: const AppToken(
    id: 331,
    name: 'BNB',
    shortName: 'BNB',
    icon: '',
    usdPrice: 921,
    prevPriceDiffPercent: 0.15,
    contractAddress: '',
    decimal: 18,
    precision: 6,
    blockchain: BlockchainInfo(
      id: 29,
      name: 'BNB Smart Chain',
      shortName: 'BSC',
      icon: '',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.bsc,
      chainId: 97,
      networkId: 97,
      supportsEIP1559: false,
    ),
    tokenWalletType: TokenWalletType.master,
    description: 'BNB Smart Chain',
  ),
);

AppAsset bscBEP20AssetExample({
  required String address,
}) => AppAsset(
  id: 212,
  balance: BigRational.one,
  hold: BigRational.zero,
  address: address,
  walletId: 4323,
  childWalletAddress: '',
  token: const AppToken(
    id: 313,
    name: 'USDT',
    shortName: 'USDT',
    icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/3408.png',
    usdPrice: 0.9992,
    prevPriceDiffPercent: 0.09,
    contractAddress: '0x337610d27c682e347c9cd60bd4b3b107c9d34ddd',
    decimal: 18,
    precision: 2,
    blockchain: BlockchainInfo(
      id: 29,
      name: 'BNB Smart Chain',
      shortName: 'BSC',
      icon: '',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.bsc,
      chainId: 97,
      networkId: 97,
      supportsEIP1559: false,
    ),
    tokenWalletType: TokenWalletType.child,
    description: 'USDT',
  ),
);
