import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

AppAsset btcAssetExample(String address) => AppAsset(
  id: 125,
  balance: 1,
  hold: 0,
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
