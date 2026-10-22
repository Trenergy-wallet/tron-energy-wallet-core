# TR.ENERGY Wallet Core Package

[TR.ENERGY Wallet](https://tr.energy/)

## Features

- create and send transactions on TRON, TON, BITCOIN blockchains
- BITCOIN RBF transactions
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
    getAuthToken: () => tronApiKey,
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
}

Future<void> tronExample(String tronAddress) async {
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();
  // Lots of TRON examples can be found here: https://github.com/mrtnetwork/On_chain/blob/main/example/lib/example
  final tronService = TransactionsServiceTronImpl(
    localRepo: localRepo,
    postTransaction: postTransactionTron,
    rpc: tronRpc,
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
    rpc: tonRpc,
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
  final localRepo = LocalRepoImpl();
  final btcNodeRepo = BTCNodeRepoImpl();
  final logger = InAppLogger();

  final btcService = TransactionsServiceBTCImpl(
    localRepo: localRepo,
    postTransaction: btcNodeRepo.postTransaction,
    btcNodeRepo: btcNodeRepo,
    estimateFee: btcNodeRepo.getEstimateFee,
    network: BitcoinNetwork.signet,
  );

  final walletInfo = await btcService.tryInitializeWalletAndGetInfoOrThrow(
    masterKey: '',
  );
  logger.logInfoMessage('btcExample', 'Address: ${walletInfo.address}');
  final btcAsset = btcAssetExample(walletInfo.address);
  final tx = await btcService.createTransactionOrThrow(
    toAddress: 'tb1p8kxn49u3saux772xy33f8295ma30zrzp8egywvxlxu6860u9ekaqx39n2y',
    amount: 0.0001,
    asset: btcAsset,
    masterKey: '',
    feeTypeBTC: FeeTypeBTC.optimal,
  );
  logger.logInfoMessage('btcExample', 'TX: $tx');
  final sentTx = await btcService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('btcExample', 'SENT: $sentTx');
}
```

See the `/example` folder for a detailed example.

## Node providers, custom HTTP client (DPoP)

The network services take a ready node provider. Build it once and keep it as long as the
service: one http client, connections are reused. The auth token is not stored in the
provider - `getAuthToken` is called on every request, so a re-login needs no new provider.
The app passes a client that adds DPoP proofs (RFC 9449), the device key stays behind
`DpopSigner`:

```dart
final tron = TransactionsServiceTronImpl(
  getSigningKey: getSigningKey,
  rpc: TronProvider(
    TronHTTPProvider(
      url: apiTron,
      getAuthToken: () => token, // Authorization: Bearer, read per request
      // the provider never closes the client, its owner does
      client: LoggingHttpClient(dpopClient, logger: logger),
    ),
  ),
);
```

Ethereum-compatible and Solana services take `EthereumProvider(EthereumHTTPProvider(...))` and
`SolanaProvider(SolanaHTTPProvider(...))` as `rpc`. TON takes
`TonProvider(provider, provider.api)` of a `TonHTTPProvider` as `rpc`; it logs the
requests itself, no `LoggingHttpClient` needed. Gasfree
(`TransactionsServiceEthereumGasFreeImpl`) takes the client itself as `httpClient`: it never closes
it.

## Issues & Feedback

Found a bug or have a feature request?  
Please open an issue in
our [GitHub Issues](https://github.com/Trenergy-wallet/tron-energy-wallet-core/issues) section.