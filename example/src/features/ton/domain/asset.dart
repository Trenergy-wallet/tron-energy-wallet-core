import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

AppAsset tonAssetExample(String address) => AppAsset(
  id: 15,
  balance: 10,
  hold: 0,
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
      // TODO(ivn): update
      chainId: -1,
      supportsEIP1559: false,
    ),
    tokenWalletType: TokenWalletType.master,
    description: '',
    precision: 2,
  ),
);
