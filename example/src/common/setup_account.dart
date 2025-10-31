import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../data/repo/local_repo_core_impl.dart';

/// Account with the wallet
///
/// returns the address of the account (tron public address)
Future<String> setupAccount({required String mnemonic}) async {
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger()
    ..usePrint = true
    ..logInfoMessage('setupAccount', mnemonic);
  // Generate mnemonic
  // final mnemonic = bip.Bip39MnemonicGenerator()
  //     .fromWordsNumber(
  //       Bip39WordsNum.wordsNum12,
  //     )
  //     .toStr();
  //
  // Or use your own (list of words with space separator)
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
  return address;
}
