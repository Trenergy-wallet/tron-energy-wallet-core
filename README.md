# TR.ENERGY Wallet Core Package

[TR.ENERGY Wallet](https://tr.energy/)

## Features

- create and send transactions on TRON, TON, BITCOIN, LITECOIN, EVM, SOLANA blockchains
- BITCOIN / LITECOIN RBF transactions
- limited TON Jetton support

## Getting started

1. Add the latest version of package to your `pubspec.yaml` and run `flutter pub get`:

```
dependencies:
  tron_energy_wallet_core:
    git:
      url: git@github.com:Trenergy-wallet/tron-energy-wallet-core.git
```

2. Import the package in your Flutter App.

```dart
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';
```

## Usage

```
final tronRpc = TronProvider(
  TronHTTPProvider(
    url: 'https://nile.trongrid.io',
    authToken: tronApiKey,
  ),
);
final tonRpc = TonProvider(
  TonHTTPProvider(
    tonApiUrl: 'https://testnet.tonapi.io',
    tonCenterUrl: 'https://testnet.toncenter.com',
    tonApiKey: tonApiKey,
  ),
);

Future<void> main() async {
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger()..usePrint = true;
  // Generate mnemonic
  // final mnemonic = bip.Bip39MnemonicGenerator()
  //     .fromWordsNumber(
  //       Bip39WordsNum.wordsNum12,
  //     )
  //     .toStr();
  //
  // Or use your own (list of words with space separator)
  const mnemonic = 'mnemonic words';
  logger.logInfoMessage('main', mnemonic);
  // Generate seed from the mnemonic
  final privateKey = await KeyGenerator(mnemonic: mnemonic).generateForTron();

  final publicKey = privateKey.publicKey();
  final address = publicKey.toAddress().toString();
  logger.logInfoMessage('main', 'TRON Address: $address');
  // It is recommended to create account contract as it stated in https://github.com/mrtnetwork/On_chain/blob/main/example/lib/example/tron/transactions/account/create_account_example.dart
  await localRepo.saveAccount(
    LocalAccount.empty.copyWith(
      token: 'your token',
      address: address,
      publicKey: publicKey.toString(),
    ),
  );
  await localRepo.saveMnemonic(
    mnemonic: mnemonic,
    publicKey: '',
    masterKey: '',
  );

  await localRepo.savePK(
    pk: privateKey.toBytes().toString(),
    publicKey: '',
    masterKey: '',
  );
  await tronExample(address);
  await tonExample();
  await btcExample();
  await ltcExample();
}

Future<void> tronExample(String tronAddress) async {
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();
  // Lots of TRON examples can be found here: https://github.com/mrtnetwork/On_chain/blob/main/example/lib/example
  final tronService = TransactionsServiceTronImpl(
    localRepo: localRepo,
    postTransaction: postTransactionTron,
    tronProvider: tronRpc,
  );

  final tronAsset = tronAssetExample(tronAddress);

  final tx = await tronService.createTransactionOrThrow(
    toAddress: 'TP8KmXDvKVYg5WVTTyqaNT61Htguw2NJBs',
    amount: 1,
    asset: tronAsset,
    masterKey: '',
  );
  logger.logInfoMessage('tronExample', 'TX: $tx');
  final sentTx = await tronService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('tronExample', 'SENT: $sentTx');
}

Future<void> tonExample() async {
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();

  final tonService = TransactionsServiceTonImpl(
    localRepo: localRepo,
    postTransaction: postTransactionTon,
    currentAccountWallet: () => null,
    isTestnet: true,
    tonProvider: tonRpc,
  );

  final walletInfo = await tonService.tryInitializeWalletAndGetInfoOrThrow(
    masterKey: '',
  );
  logger.logInfoMessage('tonExample', 'Address: ${walletInfo.address}');

  final tonAsset = tonAssetExample(walletInfo.address);
  final tx = await tonService.createTransactionOrThrow(
    toAddress: 'Uf_a4Onq2UrxzOsJWYrKWohBfVsv-cW1Gd6yTQmQF2b84L8C',
    amount: 0.05,
    asset: tonAsset,
    masterKey: '',
  );
  logger.logInfoMessage('tonExample', 'TX: $tx');
  final sentTx = await tonService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('tonExample', 'SENT: $sentTx');
}

Future<void> btcExample() async {
  final btcNodeRepo = BTCNodeRepoImpl(); // your BTCNodeRepo (Blockbook)
  final logger = InAppLogger();

  final btcService = TransactionsServiceBTCImpl(
    btcNodeRepo: btcNodeRepo,
    estimateFee: btcNodeRepo.getEstimateFee,
    network: BitcoinNetwork.signet,
    logger: logger,
    getSigningKey: (masterKey) async => 'mnemonic words',
  );

  final walletInfo = await btcService.initializeWalletAndGetInfo(
    masterKey: '',
  );
  logger.logInfoMessage('btcExample', 'Address: ${walletInfo.address}');
  final tx = await btcService.createTransaction(
    params: TransferParamsBTC(
      to: 'tb1p8kxn49u3saux772xy33f8295ma30zrzp8egywvxlxu6860u9ekaqx39n2y',
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.0001'),
      tokenWalletType: TokenWalletType.master,
      feeType: FeeType.optimal,
    ),
    masterKey: '',
  );
  logger.logInfoMessage('btcExample', 'TX: $tx');
}

/// Litecoin uses the same service: only the blockchain and the network differ.
/// The wallet address is native SegWit (ltc1q...), not Taproot
Future<void> ltcExample() async {
  // your BTCNodeRepo, e.g. a Blockbook node
  final ltcNodeRepo = LTCBlockbookRepoImpl.nowNodes(
    apiKey: 'api-key',
    isTestnet: true,
  );
  final logger = InAppLogger();

  final ltcService = TransactionsServiceBTCImpl(
    appBlockchain: AppBlockchain.litecoin,
    btcNodeRepo: ltcNodeRepo,
    estimateFee: ltcNodeRepo.getEstimateFee,
    network: LitecoinNetwork.testnet,
    logger: logger,
    getSigningKey: (masterKey) async => 'mnemonic words',
  );

  final walletInfo = await ltcService.initializeWalletAndGetInfo(
    masterKey: '',
  );
  logger.logInfoMessage('ltcExample', 'Address: ${walletInfo.address}');
  final tx = await ltcService.createTransaction(
    params: TransferParamsBTC(
      appBlockchain: AppBlockchain.litecoin,
      to: walletInfo.address,
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.0001'),
      tokenWalletType: TokenWalletType.master,
      feeType: FeeType.optimal,
    ),
    masterKey: '',
  );
  logger.logInfoMessage('ltcExample', 'TX: $tx');
}
```

See the `/example` folder for a detailed example.

## Issues & Feedback

Found a bug or have a feature request?  
Please open an issue in
our [GitHub Issues](https://github.com/Trenergy-wallet/tron-energy-wallet-core/issues) section.