import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

// https://docs.optimism.io/op-mainnet/network-information/connecting-to-op
AppAsset opEthAssetExample({
  required String address,
  required bool supportsEIP1559,
  required bool isMainnet,
}) => AppAsset(
  id: 1225,
  balance: BigRational.one,
  hold: BigRational.zero,
  address: address,
  walletId: 3821,
  childWalletAddress: '',
  token: AppToken(
    id: 551,
    name: 'Ethereum',
    shortName: 'ETH',
    icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
    usdPrice: 3003,
    prevPriceDiffPercent: 0.1,
    contractAddress: '',
    decimal: 18,
    precision: 6,
    blockchain: BlockchainInfo(
      id: 190,
      name: 'Optimism',
      shortName: 'OP',
      icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.optimism,
      chainId: isMainnet ? 10 : 11155420,
      networkId: isMainnet ? 10 : 11155420,
      supportsEIP1559: supportsEIP1559,
    ),
    tokenWalletType: TokenWalletType.master,
    description: 'Ethereum on optimism',
  ),
);

AppAsset opUSDCTestnetAssetExample({
  required String address,
  required bool supportsEIP1559,
}) => AppAsset(
  id: 115,
  balance: BigRational.one,
  hold: BigRational.zero,
  address: address,
  walletId: 433,
  childWalletAddress: '',
  token: AppToken(
    id: 543,
    name: 'USDC',
    shortName: 'USDC',
    icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/3408.png',
    usdPrice: 0.9992,
    prevPriceDiffPercent: 0.09,
    contractAddress: '0x5fd84259d66Cd46123540766Be93DFE6D43130D7',
    decimal: 6,
    precision: 2,
    blockchain: BlockchainInfo(
      id: 190,
      name: 'Optimism',
      shortName: 'OP',
      icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.optimism,
      chainId: 11155420,
      networkId: 11155420,
      supportsEIP1559: supportsEIP1559,
    ),
    tokenWalletType: TokenWalletType.child,
    description: 'USDC',
  ),
);
