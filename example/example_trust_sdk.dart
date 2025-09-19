import 'package:blockchain_utils/hex/hex.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:trust_wallet_core/flutter_trust_wallet_core.dart';
import 'package:trust_wallet_core/protobuf/Ethereum.pb.dart' as ethereum;
import 'package:trust_wallet_core/trust_wallet_core_ffi.dart';

import 'src/data/remote/eth/eth_node_repo_impl.dart';

const ethApiKey = 'your-api-key';

Future<void> main() async {
  const name = 'Eth example';
  final logger = InAppLogger()..usePrint = true;
  final nodeRepo = ETHNodeRepoImpl();

  // Generate mnemonic
  // final mnemonic = bip.Bip39MnemonicGenerator()
  //     .fromWordsNumber(
  //       Bip39WordsNum.wordsNum12,
  //     )
  //     .toStr();
  //
  // Or use your own (list of words with space separator)
  const prod1 = 'mnemonic1';

  const mnemonic = prod1;
  logger.logInfoMessage(name, mnemonic);
  FlutterTrustWalletCore.init(useCliLib: true);
  final mnemonicIsValid = TWMnemonicImpl.isValid(mnemonic);
  logger.logInfoMessage(name, 'is valid: $mnemonicIsValid');
  final wallet = HDWallet.createWithMnemonic(mnemonic);
  logger.logInfoMessage(name, 'mnemonic from wallet: ${wallet.mnemonic()}');

  final publicKey = wallet
      .getKeyForCoin(TWCoinType.TWCoinTypeEthereum)
      .getPublicKeySecp256k1(false);
  final anyAddress = AnyAddress.createWithPublicKey(
    publicKey,
    TWCoinType.TWCoinTypeEthereum,
  );
  logger.logInfoMessage(
    name,
    'address from any address: ${anyAddress.description()}',
  );
  final pk = wallet.getKeyForCoin(TWCoinType.TWCoinTypeEthereum);
  final privateKeyhex = hex.encode(pk.data());
  logger
    ..logInfoMessage(name, 'privateKeyhex: $privateKeyhex')
    ..logInfoMessage(name, 'seed = ${hex.encode(wallet.seed())}');
  // final keystore = StoredKey.importPrivateKey(
  //   wallet.getKeyForCoin(TWCoinType.TWCoinTypeEthereum).data(),
  //   'name',
  //   'password',
  //   TWCoinType.TWCoinTypeEthereum,
  // );
  // print('keystore: ${keystore?.exportJson()}');

  const gasPrice = 1.214 * 1000000000; // Gwei * 1000000000
  const nonce = 0; // get from endpoint
  const gasLimit = 21000; // get from endpoint
  const amount = 0.00001 * 1000000000000000000; // ETH * 10^18
  logger
    ..logInfoMessage(
      name,
      'gas price '
      'gwei: $gasPrice : ${(gasPrice * 1000000000).toInt().toRadix16}',
    ) // 0x486A6B00
    ..logInfoMessage(name, 'nonce: $nonce : ${nonce.toRadix16}') // 00
    ..logInfoMessage(
      name,
      'gasLimit: $gasLimit : ${gasLimit.toRadix16}',
    ); // 5208

  final hexValue = amount.toInt().toRadix16;
  final valueInWei = BigInt.parse('0x$hexValue');
  final valueInEth = valueInWei / BigInt.from(10).pow(18);

  logger.logInfoMessage(
    name,
    'amount: $valueInEth : $hexValue',
  ); // 0de0b6b3a7640000

  final input = ethereum.SigningInput(
    privateKey: pk.data(),
    // mainnet
    chainId: hex.decode('01'),
    // N p/p in wallet - get from endpoint
    nonce: hex.decode(nonce.toRadix16),
    // get from endpoint
    gasPrice: hex.decode(gasPrice.toInt().toRadix16),
    gasLimit: hex.decode(gasLimit.toRadix16),
    toAddress: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
    transaction: ethereum.Transaction(
      transfer: ethereum.Transaction_Transfer(
        amount: hex.decode(amount.toInt().toRadix16),
      ),
    ),
  );
  logger.logInfoMessage(
    name,
    'amount: ${hex.encode(input.transaction.transfer.amount)}',
  );

  final signed = AnySigner.sign(
    input.writeToBuffer(),
    TWCoinType.TWCoinTypeEthereum,
  );

  final output = ethereum.SigningOutput.fromBuffer(signed);

  // Now you can submit the encoded output to the network

  final draft = hex.encode(output.encoded);
  logger.logInfoMessage(name, 'raw tr hex: $draft');
  // final res = await nodeRepo.sendRawTransaction(rawTransaction: '0x$draft');
  // logger.logInfoMessage(name, 'res: $res');
}

extension ToRadix16 on int {
  String get toRadix16 {
    final radix = toRadixString(16);
    return '${radix.length.isOdd ? 0 : ''}$radix';
  }
}
