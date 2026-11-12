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

Each network service takes a ready node provider (`rpc`), see
[Node providers](#node-providers-custom-http-client-dpop) below.

```dart
final tronRpc = TronProvider(
  TronHTTPProvider(
    url: 'https://nile.trongrid.io',
    getAuthorization: () => 'Bearer $tronApiKey',
  ),
);

final tonHttp = TonHTTPProvider(
  tonApiUrl: 'https://testnet.tonapi.io',
  tonCenterUrl: 'https://testnet.toncenter.com',
  tonApiKey: tonApiKey,
);
final tonRpc = TonProvider(tonHttp, tonHttp.api);

Future<void> tronExample() async {
  final privateKey = await KeyGenerator(mnemonic: mnemonic).generateForTron();
  final service = TransactionsServiceTronImpl(
    rpc: tronRpc,
    getSigningKey: (masterKey) async => privateKey,
  );

  // Signed transaction JSON
  final tx = await service.createTransaction(
    params: TransferParamsTRON(
      to: 'TP8KmXDvKVYg5WVTTyqaNT61Htguw2NJBs',
      from: privateKey.publicKey().toAddress().toString(),
      amount: BigRational.parseDecimal('1'),
      tokenWalletType: TokenWalletType.master,
      tokenDecimal: 6,
      tokenContractAddress: null,
    ),
    masterKey: '',
  );
  final transaction = Transaction.fromJson(json.decode(tx) as Map<String, dynamic>);
  await tronRpc.request(TronRequestBroadcastHex(transaction: transaction.toHex));
}

Future<void> tonExample() async {
  final service = TransactionsServiceTonImpl(
    rpc: tonRpc,
    currentAccountWallet: () => null,
    isTestnet: true,
    getSigningKey: (masterKey) async => mnemonic,
  );

  final walletInfo = await service.initializeWalletAndGetInfo(masterKey: '');
  // Signed BOC
  final tx = await service.createTransaction(
    params: TransferParamsTON(
      to: 'Uf_a4Onq2UrxzOsJWYrKWohBfVsv-cW1Gd6yTQmQF2b84L8C',
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.05'),
      tokenWalletType: TokenWalletType.master,
    ),
    masterKey: '',
  );
  await tonRpc.request(TonCenterSendBocReturnHash(tx));
}
```

Bitcoin and Litecoin share one service, `TransactionsServiceBTCImpl`: only `appBlockchain` and
`network` differ. Instead of `rpc` it takes a `BTCNodeRepo` (Blockbook), implemented by the app.
The Bitcoin wallet address is Taproot (`bc1p...`), the Litecoin one is native SegWit
(`ltc1q...`, BIP-84 `m/84'/2'/0'/0/0`): `ltc1p...` recipients are rejected.

```dart
Future<void> ltcExample() async {
  // your BTCNodeRepo, see example/src/features/ltc/data/repo
  final nodeRepo = LTCBlockbookRepoImpl.nowNodes(apiKey: apiKey, isTestnet: true);

  final service = TransactionsServiceBTCImpl(
    // Bitcoin: omit appBlockchain (bitcoin by default), network: BitcoinNetwork.signet
    appBlockchain: AppBlockchain.litecoin,
    network: LitecoinNetwork.testnet,
    btcNodeRepo: nodeRepo,
    estimateFee: nodeRepo.getEstimateFee,
    getSigningKey: (masterKey) async => mnemonic,
  );

  final walletInfo = await service.initializeWalletAndGetInfo(masterKey: '');
  // Signed raw transaction, RBF enabled
  final tx = await service.createTransaction(
    params: TransferParamsBTC(
      // Bitcoin: omit appBlockchain here as well
      appBlockchain: AppBlockchain.litecoin,
      to: 'tltc1q...',
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.0001'),
      tokenWalletType: TokenWalletType.master,
      feeType: FeeType.optimal,
    ),
    masterKey: '',
  );
  await nodeRepo.broadcast(tx);
}
```

Full Bitcoin and Litecoin examples, Ethereum-compatible networks, Solana and gasfree: see
`/example`.


## Node providers, custom HTTP client (DPoP)

The network services take a ready node provider. Build it once and keep it as long as the
service: one http client, connections are reused. The `Authorization` header is not stored in
the provider - `getAuthorization` is called on every request, so a re-login needs no new
provider. It returns the whole value with its scheme (`Bearer …`, `DPoP …`), sent as is.
The app passes its own client, e.g. one that adds DPoP proofs (RFC 9449):

```dart
final tron = TransactionsServiceTronImpl(
  getSigningKey: getSigningKey,
  rpc: TronProvider(
    TronHTTPProvider(
      url: apiTron,
      getAuthorization: () => authorization, // `DPoP …`, read per request
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