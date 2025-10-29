import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

AppAsset ethAssetExample({
  required String address,
  required bool supportsEIP1559,
}) => AppAsset(
  id: 1225,
  balance: 1,
  hold: 0,
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
      id: 19,
      name: 'Ethereum',
      shortName: 'ETH',
      icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.ethereum,
      chainId: 11155111,
      supportsEIP1559: supportsEIP1559,
    ),
    tokenWalletType: TokenWalletType.master,
    description:
        'Ethereum is a decentralized open-source blockchain system that '
        'features its own cryptocurrency, Ether. ETH works as a platform '
        'for numerous other cryptocurrencies, as well as for the execution '
        'of decentralized smart contracts.',
  ),
);

AppAsset ethERC20AssetExample({
  required String address,
  required bool supportsEIP1559,
}) => AppAsset(
  id: 115,
  balance: 1,
  hold: 0,
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
    contractAddress: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
    decimal: 6,
    precision: 2,
    blockchain: BlockchainInfo(
      id: 19,
      name: 'Ethereum',
      shortName: 'ETH',
      icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
      isNew: false,
      tokens: [],
      appBlockchain: AppBlockchain.ethereum,
      chainId: 11155111,
      supportsEIP1559: supportsEIP1559,
    ),
    tokenWalletType: TokenWalletType.child,
    description: 'USDC',
  ),
);
