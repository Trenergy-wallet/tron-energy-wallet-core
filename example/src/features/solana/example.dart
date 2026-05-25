import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';
import 'package:tron_energy_wallet_core/src/features/networks/networks.dart';
import 'package:tron_energy_wallet_core/src/features/networks/solana/domain/token_type.dart';

final _logger = InAppLogger()..usePrint = true;

// Per 1 signature
// const int _baseFeeLamports = 5000;
// const _addFeeInstruction = false;
const useTestnet = true;
const String _amount = '300';

// https://faucet.solana.com/
// https://explorer.solana.com/?cluster=devnet
// DEVNET

// USDC decimal: 6
// USDC contractAddress:
const String _usdcContractAddress = useTestnet
    ? '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU'
    : 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

const String _ustContractAddress = useTestnet
    ? ''
    : 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB';

/// T1 authority, userLT1 mint
const String _testToken2022 = 'token';

Future<void> main() async {
  const name = 'SOLExample';
  final rpc = SolanaProvider(
    SolanaHTTPProvider(
      url: useTestnet
          ? 'https://api.devnet.solana.com'
          : 'https://api.mainnet.solana.com',
    ),
  );

  const prod1 = 'mnemonic';
  const prod2 = 'mnemonic';

  const user1 = 'mnemonic';
  const user2 = 'mnemonic';

  // 7qXUiyk7qS7QdtaiGhCmRRRimg6y5EuoSEnJb6x6s3xZ = mint contract
  const userLT1 = 'mnemonic';

  const from = user2;
  const to = user1;

  final generatorFrom = KeyGenerator(mnemonic: from);
  final generatorTo = KeyGenerator(mnemonic: to);

  final pkFrom = await generatorFrom.generateForSolana(forTestnet: useTestnet);
  final pkTo = await generatorTo.generateForSolana(forTestnet: useTestnet);

  final addressFrom = pkFrom.publicKey().toAddress();
  final addressTo = pkTo.publicKey().toAddress();

  final bal1 = await rpc.request(
    SolanaRequestGetBalance(account: addressFrom),
  );
  _logger.logInfoMessage(name, 'wallet1: $addressFrom, balance: $bal1');
  //
  /// Retrieve the account information for a specific address.
  // final accountModel = await service.request(
  //   SolanaRequestGetAccountInfo(account: addressFrom),
  // );
  // logger.logInfoMessage(name, 'account: $accountModel');

  final bal2 = await rpc.request(
    SolanaRequestGetBalance(account: addressTo),
  );

  _logger.logInfoMessage(name, 'wallet2: $addressTo, balance: $bal2');

  final mintAddress = SolAddress(_testToken2022);
  final mintInfo = await rpc.request(
    SolanaRequestGetAccountInfo(
      account: mintAddress,
      dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
    ),
  );

  final tokenType = SolTokenType.fromOwner(mintInfo?.owner);

  // 1. Вычисляем ATA (Associated Token Account) для отправителя и получателя
  // Используем утилиту из вашего файла create_associated_token_account.dart
  final sourceATA = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
    mint: mintAddress,
    owner: addressFrom,
    tokenProgramId: tokenType.programId,
  );

  final balFromATA = await rpc.request(
    SolanaRequestGetTokenAccountBalance(
      account: sourceATA.address,
      commitment: Commitment.processed,
    ),
  );
  _logger.logInfoMessage(
    name,
    'TOKEN FROM address: ${sourceATA.address}, '
    'balance: ${balFromATA.uiAmountString}, type: $tokenType',
  );

  final destinationATA =
      AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: mintAddress,
        owner: addressTo,
        tokenProgramId: tokenType.programId,
      );
  try {
    final balToATA = await rpc.request(
      SolanaRequestGetTokenAccountBalance(
        account: destinationATA.address,
        commitment: Commitment.processed,
      ),
    );
    _logger.logInfoMessage(
      name,
      'TOKEN TO address: ${destinationATA.address}, '
      'balance: ${balToATA.uiAmountString}, type: $tokenType',
    );
  } catch (e) {
    _logger.logInfoMessage(name, 'destinationATA error: $e');
  }

  final service = TransactionsServiceSolanaImpl(
    getSigningKey: (_) async => from,
    isTestnet: useTestnet,
    rpc: rpc,
  );

  // Test Token 2022
  final params = TransferParamsSOL(
    to: addressTo.address,
    from: addressFrom.address,
    amount: BigRational.parseDecimal(_amount),
    tokenDecimal: 6,
    tokenWalletType: .child,
    usePriorityFee: false,
    tokenContractAddress: mintAddress.address,
    // message: 'hi sol',
  );

  // USDC
  // final params = TransferParamsSOL(
  //   to: addressTo.address,
  //   from: addressFrom.address,
  //   amount: BigRational.parseDecimal(_amount),
  //   tokenDecimal: 6,
  //   tokenWalletType: .child,
  //   usePriorityFee: true,
  //   tokenContractAddress: _usdcContractAddress,
  //   // message: 'hi sol',
  // );
  // SOL
  // final params =
  //   TransferParamsSOL(
  //     to: addressTo.address,
  //     from: addressFrom.address,
  //     amount: BigRational.parseDecimal(_amount),
  //     tokenDecimal: SolanaUtils.decimal,
  //     tokenWalletType: .master,
  //     usePriorityFee: false,
  //     // tokenContractAddress: _usdcContractAddress,
  //     // message: 'hi sol',
  //
  // );

  // _logger.logInfoMessage(
  //   name,
  //   'Fee params: fee: ${params.priorityFeeMicrolamports}, '
  //   'cu: ${params.cuLimit}',
  // );

  final tx = await service.createTransaction(
    params: params,
    masterKey: '',
  );

  // final tx = service.createTransaction(
  //   params: TransferParamsSOL(
  //     to: addressTo.address,
  //     from: addressFrom.address,
  //     amount: BigRational.parseDecimal(_amount),
  //     chainId: 0,
  //     tokenDecimal: 6,
  //     tokenWalletType: .child,
  //     tokenContractAddress: _usdcContractAddress,
  //   ),
  //   masterKey: '',
  // );

  // /// Retrieve the latest block hash.
  // final recentBlock = await rpc.request(
  //   const SolanaRequestGetLatestBlockhash(),
  // );
  //
  // final instructions = <TransactionInstruction>[];

  // ===== Mint start
  // final mintAccSpace = SolanaMintAccount.size;
  // final rent = await rpc.request(
  //   SolanaRequestGetMinimumBalanceForRentExemption(size: mintAccSpace),
  // );
  // final createAccount = SystemProgram.createAccount(
  //   from: addressFrom,
  //   newAccountPubKey: addressTo,
  //   layout: SystemCreateLayout(
  //     lamports: rent,
  //     space: BigInt.from(mintAccSpace),
  //     programId: SPLTokenProgramConst.token2022ProgramId,
  //   ),
  // );
  //
  // final mint = SPLTokenProgram.initializeMint2(
  //   layout: SPLTokenInitializeMint2Layout(
  //     mintAuthority: addressFrom,
  //     decimals: 6,
  //   ),
  //   mint: addressTo,
  //   programId: SPLTokenProgramConst.token2022ProgramId,
  // );
  // final tx = SolanaTransaction(
  //   payerKey: addressFrom,
  //   instructions: [createAccount, mint],
  //   recentBlockhash: recentBlock.blockhash,
  // )..sign([pkFrom, pkTo]);
  // ===== Mint end

  // ====== Mint to Start
  // final mintAddress = SolAddress.unchecked(
  //   '7qXUiyk7qS7QdtaiGhCmRRRimg6y5EuoSEnJb6x6s3xZ',
  // );
  // final destinationTokenAccount =
  //     AssociatedTokenAccountProgramUtils.associatedTokenAccount(
  //       mint: mintAddress,
  //       owner: addressTo,
  //       tokenProgramId: SPLTokenProgramConst.token2022ProgramId,
  //     );
  //
  // final createATA = AssociatedTokenAccountProgram.associatedTokenAccount(
  //   payer: addressFrom,
  //   associatedToken: destinationTokenAccount.address,
  //   owner: addressTo,
  //   mint: mintAddress,
  //   tokenProgramId: SPLTokenProgramConst.token2022ProgramId,
  // );
  //
  // final mintTo = SPLTokenProgram.mintTo(
  //   mint: mintAddress,
  //   destination: destinationTokenAccount.address,
  //   authority: addressFrom,
  //   programId: SPLTokenProgramConst.token2022ProgramId,
  //   layout: SPLTokenMintToLayout(amount: BigInt.from(1000000000)),
  // );
  //
  // final tx = SolanaTransaction(
  //   payerKey: addressFrom,
  //   instructions: [createATA, mintTo],
  //   recentBlockhash: recentBlock.blockhash,
  // )..sign([pkFrom]);
  // ====== Mint to end

  // === wSol Start
  // ======== Начало отправки Баланса SOL
  // const mintAddress = SPLTokenProgramConst.nativeMint2022;
  // const programId = SPLTokenProgramConst.token2022ProgramId;
  //
  // final destinationATA =
  //     AssociatedTokenAccountProgramUtils.associatedTokenAccount(
  //       mint: mintAddress,
  //       owner: addressFrom,
  //       programId: programId,
  //     );
  // instructions.addAll(
  //   [
  //     // AssociatedTokenAccountProgram.associatedTokenAccount(
  //     //   payer: addressFrom,
  //     //   associatedToken: destinationATA.address,
  //     //   owner: addressFrom,
  //     //   mint: mintAddress,
  //     //   tokenProgramId: programId,
  //     // ),
  //     SystemProgram.transfer(
  //       from: addressFrom,
  //       to: destinationATA.address,
  //       layout: SystemTransferLayout(lamports: SolanaUtils.toLamports(_amount)),
  //     ),
  //     // Синхронизируем баланс внутри программы Token-2022
  //     SPLTokenProgram.syncNative(
  //       account: destinationATA.address,
  //       programId: programId,
  //     ),
  //   ],
  // );

  // === wSol End

  // final transferInstruction = SystemProgram.transfer(
  //   from: addressFrom,
  //   layout: SystemTransferLayout(
  //     lamports: SolanaUtils.toLamports(_amount),
  //   ),
  //   to: addressTo,
  // );

  // instructions.add(transferInstruction);
  // ======== Конец отправки Баланса SOL

  // ======== Начало отправки токена

  // final sendInfo = await rpc.request(
  //   SolanaRequestGetAccountInfo(account: sourceATA.address),
  // );
  // _logger.logInfoMessage(name, 'sendInfo: ${sendInfo?.toJson()}');
  //
  // // 2. Проверяем, существует ли ATA у получателя
  // final destinationInfo = await rpc.request(
  //   SolanaRequestGetAccountInfo(
  //     account: destinationATA.address,
  //     // dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
  //   ),
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
  //   type: TransactionType.v0,
  // );
  //
  // /// Sign the transaction with the owner's private key.
  // final ownerSignature = pkFrom.sign(tx.serializeMessage());
  // tx.addSignature(addressFrom, ownerSignature);

  // _logger.logInfoMessage('tx ready:', tx.serializeString());
  // final simulatedResult = await rpc.request(
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
  //
  /// Send the transaction to the Solana network.
  // final res = await rpc.request(
  //   SolanaRequestSendTransaction(encodedTransaction: tx.serializeString()),
  // );

  // final res = await rpc.request(
  //   SolanaRequestSendTransaction(encodedTransaction: tx),
  // );
  //
  // _logger.logInfoMessage(name, 'Result: $res');
}
