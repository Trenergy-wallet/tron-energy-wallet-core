import 'package:on_chain/tron/src/provider/provider/provider.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:ton_wallet_service/ton_wallet_service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'src/data/local/local_repo_core_impl.dart';
import 'src/example_assets.dart';

const tonApiKey = 'your-api-key';

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
}

Future<void> tronExample(String tronAddress) async {
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();
  // Lots of TRON examples can be found here: https://github.com/mrtnetwork/On_chain/blob/main/example/lib/example
  final tronService = TransactionsServiceTronImpl(
    localRepo: localRepo,
    postTransaction: postTransactionTron,
    tronProvider: TronProvider(
      TronHTTPProvider(
        url: 'https://nile.trongrid.io',
        authToken: 'your-token',
      ),
    ),
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
    tonProvider: TonProvider(
      TonHTTPProvider(
        tonApiUrl: 'https://testnet.tonapi.io',
        tonCenterUrl: 'https://testnet.toncenter.com',
        tonApiKey: tonApiKey,
      ),
    ),
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
