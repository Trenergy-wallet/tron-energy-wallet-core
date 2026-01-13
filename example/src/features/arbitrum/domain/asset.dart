import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

AppAsset arbAssetExample({
  required String address,
}) => AppAsset(
  id: 1234,
  balance: BigRational.one,
  hold: BigRational.zero,
  address: address,
  walletId: 24432,
  childWalletAddress: '',
  token: const AppToken(
    id: 235,
    name: 'Arbitrum',
    shortName: 'ARB',
    icon: '',
    usdPrice: 0.2003,
    prevPriceDiffPercent: 0.13,
    contractAddress: '',
    decimal: 18,
    precision: 6,
    blockchain: BlockchainInfo(
      id: 34,
      name: 'Arbitrum Sepolia',
      shortName: 'ARB',
      icon: '',
      isNew: true,
      tokens: [],
      appBlockchain: AppBlockchain.arbitrum,
      chainId: 421614,
      networkId: 421614,
      supportsEIP1559: true,
    ),
    tokenWalletType: TokenWalletType.master,
    description: 'Arbitrum Sepolia',
  ),
);

AppAsset arbBEP20AssetExample({
  required String address,
}) => AppAsset(
  id: 322,
  balance: BigRational.one,
  hold: BigRational.zero,
  address: address,
  walletId: 12443,
  childWalletAddress: '',
  token: const AppToken(
    id: 23545,
    name: 'USDC',
    shortName: 'USDC',
    icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/3408.png',
    usdPrice: 0.9995,
    prevPriceDiffPercent: 0.09,
    contractAddress: '0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d',
    decimal: 6,
    precision: 2,
    blockchain: BlockchainInfo(
      id: 34,
      name: 'Arbitrum Sepolia',
      shortName: 'ARB',
      icon: '',
      isNew: true,
      tokens: [],
      appBlockchain: AppBlockchain.arbitrum,
      chainId: 421614,
      networkId: 421614,
      supportsEIP1559: true,
    ),
    tokenWalletType: TokenWalletType.child,
    description: 'USDC',
  ),
);
