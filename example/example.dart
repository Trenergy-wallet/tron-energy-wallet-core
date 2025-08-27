import 'package:on_chain/tron/src/provider/provider/provider.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'src/data/local/local_repo_core_impl.dart';
import 'src/example_assets.dart';

Future<void> main() async {
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();
  // Generate mnemonic
  // final mnemonic = bip.Bip39MnemonicGenerator()
  //     .fromWordsNumber(
  //       Bip39WordsNum.wordsNum12,
  //     )
  //     .toStr();
  //
  // Or use your own (list of words with space separator)
  const mnemonic = '';
  logger.logInfoMessage('main', mnemonic);
  // Generate seed from the mnemonic
  final privateKey = await KeyGenerator(mnemonic: mnemonic).generateForTron();

  final publicKey = privateKey.publicKey();
  final address = publicKey.toAddress().toString();
  logger.logInfoMessage('main', 'Address: $address');
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

  final tronAsset = tronAssetExample(address);

  final tx = await tronService.createTransactionOrThrow(
    toAddress: 'TP8KmXDvKVYg5WVTTyqaNT61Htguw2NJBs',
    amount: 1,
    asset: tronAsset,
    masterKey: '',
  );
  logger.logInfoMessage('main', 'TX: $tx');
  final sentTx = await tronService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('main', 'SENT: $sentTx');
}
