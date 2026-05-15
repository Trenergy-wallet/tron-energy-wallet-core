import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';
import 'package:tron_energy_wallet_core/src/features/networks/networks.dart';

final _logger = InAppLogger()..usePrint = true;

// Per 1 signature
const int _baseFeeLamports = 5000;
const _addFeeInstruction = false;

// https://faucet.solana.com/
// https://explorer.solana.com/?cluster=devnet
// DEVNET

// USDC decimal: 6
// USDC contractAddress:
const _usdcContractAddressDevNet =
    '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU';
const _usdcContractAddress = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

Future<void> main() async {
  const name = 'SOLExample';
  final rpc = SolanaProvider(
    SolanaHTTPProvider(url: 'https://api.devnet.solana.com'),
  );

  const user1 = 'mnem1';
  const user2 = 'mnem2';
  final generator1 = KeyGenerator(mnemonic: user1);
  final generator2 = KeyGenerator(mnemonic: user2);

  final pk1 = await generator1.generateForSolana(forTestnet: true);
  final pk2 = await generator2.generateForSolana(forTestnet: true);

  final from = pk1;
  final to = pk2;

  final addressFrom = from.publicKey().toAddress();
  final addressTo = to.publicKey().toAddress();

  final bal1 = await rpc.request(
    SolanaRequestGetBalance(account: addressFrom),
  );
  _logger.logInfoMessage(name, 'wallet1: $addressFrom, balance: $bal1');

  /// Retrieve the account information for a specific address.
  // final accountModel = await service.request(
  //   SolanaRequestGetAccountInfo(account: addressFrom),
  // );
  // logger.logInfoMessage(name, 'account: $accountModel');

  final bal2 = await rpc.request(
    SolanaRequestGetBalance(account: addressTo),
  );

  _logger.logInfoMessage(name, 'wallet2: $addressTo, balance: $bal2');

  final service = TransactionsServiceSolanaImpl(
    getSigningKey: (_) async => user1,
    isTestnet: true,
    rpc: rpc,
  );
  final tx = service.createTransaction(
    params: TransferParamsSOL(
      to: addressTo.address,
      from: addressFrom.address,
      amount: BigRational.parseDecimal('1'),
      chainId: 0,
      tokenDecimal: 6,
      tokenWalletType: .child,
      tokenContractAddress: _usdcContractAddressDevNet,
    ),
    masterKey: '',
  );

  // /// Retrieve the latest block hash.
  // final recentBlock = await service.request(
  //   const SolanaRequestGetLatestBlockhash(),
  // );
  //
  // final instructions = <TransactionInstruction>[];

  // ======== Начало отправки Баланса SOL

  // final amountToSend = bal1 - _baseFeeLamports.toBigInt;
  // final amountToSend = SolanaUtils.toLamports('1');
  // _logger.logInfoMessage(
  //   name,
  //   'amountToSend: balance: $bal1, to send: $amountToSend',
  // );
  //
  // /// Create a transfer instruction to move funds from the owner to the receiver.
  // final transferInstruction = SystemProgram.transfer(
  //   from: addressFrom,
  //   layout: SystemTransferLayout(
  //     lamports: amountToSend,
  //   ),
  //   to: addressTo,
  // );
  //
  // instructions.add(transferInstruction);
  // ======== Конец отправки Баланса SOL

  // ======== Начало отправки токена

  // final mintAddress = SolAddress(_usdcContractAddressDevNet);
  // // 1. Вычисляем ATA (Associated Token Account) для отправителя и получателя
  // // Используем утилиту из вашего файла create_associated_token_account.dart
  // final sourceATA = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
  //   mint: mintAddress,
  //   owner: addressFrom,
  // );
  //
  // final sendInfo = await service.request(
  //   SolanaRequestGetAccountInfo(account: sourceATA.address),
  // );
  // _logger.logInfoMessage(name, 'sendInfo: ${sendInfo?.toJson()}');
  //
  // final destinationATA =
  //     AssociatedTokenAccountProgramUtils.associatedTokenAccount(
  //       mint: mintAddress,
  //       owner: addressTo,
  //     );
  //
  // // 2. Проверяем, существует ли ATA у получателя
  // final destinationInfo = await service.request(
  //   SolanaRequestGetAccountInfo(account: destinationATA.address),
  // );
  //
  // _logger.logInfoMessage(name, 'destinationInfo: ${destinationInfo?.toJson()}');
  //
  // // 3. Если аккаунта нет, добавляем инструкцию создания (из вашего файла)
  // if (destinationInfo == null) {
  //   instructions.add(
  //     AssociatedTokenAccountProgram.associatedTokenAccount(
  //       payer: addressFrom,
  //       associatedToken: destinationATA.address,
  //       owner: addressTo,
  //       mint: mintAddress,
  //     ),
  //   );
  // }
  //
  // // 4. Добавляем инструкцию перевода токенов (SPL Token Transfer)
  // // Мы используем transferChecked для дополнительной безопасности (нужно знать decimals)
  // // Для простоты используем стандартный transfer
  // instructions.add(
  //   SPLTokenProgram.transfer(
  //     source: sourceATA.address,
  //     destination: destinationATA.address,
  //     owner: addressFrom,
  //     layout: SPLTokenTransferLayout(
  //       amount: DecimalConverter.toBigInt(
  //         amount: BigRational.parseDecimal('0.1').toString(),
  //         decimals: 6, // usdc
  //       ),
  //     ),
  //   ),
  // );
  //
  // // ======== Конец отправки токена
  // final tx = SolanaTransaction(
  //   payerKey: addressFrom,
  //   instructions: instructions,
  //   recentBlockhash: recentBlock.blockhash,
  //   type: TransactionType.v0, // Используем современный тип транзакций
  // );
  //
  // /// Sign the transaction with the owner's private key.
  // final ownerSignature = from.sign(tx.serializeMessage());
  // tx.addSignature(addressFrom, ownerSignature);
  //
  // final simulatedResult = await service.request(
  //   SolanaRequestSimulateTransaction(
  //     encodedTransaction: tx.serializeString(),
  //     sigVerify: false,
  //   ),
  // );
  //
  // _logger.logInfoMessage(
  //   name,
  //   'simulatedResultToken: ${simulatedResult.toJson()}',
  // );

  /// Send the transaction to the Solana network.
  // final res = await service.request(
  //   SolanaRequestSendTransaction(encodedTransaction: tx.serializeString()),
  // );
  //
  // _logger.logInfoMessage(name, 'Result: $res');
}

Future<int> getPriorityFeePrices(
  SolanaProvider service,
  List<SolAddress> addresses,
) async {
  final feePrices = await service.request(
    SolanaRequestGetRecentPrioritizationFees(addresses: addresses),
  );
  final medFee =
      feePrices.map((e) => e.prioritizationFee).reduce((a, b) => a + b) ~/
      feePrices.length;
  _logger.logInfoMessage('getPriorityFeePrices', 'medFee: $medFee');
  return medFee;
}

Future<int> calculatePriorityFee(
  int feePrice,
  int unitsConsumed,
) async {
  final unitsWithGap = unitsConsumed * 12 ~/ 10;
  return unitsWithGap * feePrice ~/ 1000000;
}
