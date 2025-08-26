import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'src/data/local/local_repo_core_impl.dart';
import 'src/example_assets.dart';

Future<void> main() async {
  final localRepo = LocalRepoImpl();

  // Generate mnemonic
  // final mnemonic = bip.Bip39MnemonicGenerator()
  //     .fromWordsNumber(
  //       Bip39WordsNum.wordsNum12,
  //     )
  //     .toStr();
  //
  // Or use your own (list of words with space separator)
  const mnemonic = '';
  print(mnemonic);
  // Generate seed from the mnemonic
  final privateKey = await KeyGenerator(mnemonic: mnemonic).generateForTron();

  final publicKey = privateKey.publicKey();
  final address = publicKey.toAddress().toString();
  print('Address: $address');

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

  final tronService = TransactionsServiceTronImpl(
    localRepo: localRepo,
    postTransaction: postTransaction,
    apiTron: 'https://nile.trongrid.io',
  );

  final tronAsset = tronAssetExample(address);

  final tx = await tronService.createTransactionOrThrow(
    toAddress: 'TP8KmXDvKVYg5WVTTyqaNT61Htguw2NJBs',
    amount: 1,
    asset: tronAsset,
    masterKey: '',
  );
  print('TX: $tx');
}
