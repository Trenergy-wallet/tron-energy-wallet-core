import 'package:on_chain/on_chain.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';
import 'package:tron_energy_wallet_core/src/features/networks/networks.dart';

final _logger = InAppLogger()..usePrint = true;
const _name = 'SOLExample-mint';
final _rpc = SolanaProvider(
  SolanaHTTPProvider(
    url: _useTestnet
        ? 'https://api.devnet.solana.com'
        : 'https://api.mainnet.solana.com',
  ),
);

const _user1 = 'mnemonic 12 words';
const _user2 = 'mnemonic 12 words';

const _useTestnet = true;

// https://faucet.solana.com/
// https://explorer.solana.com/?cluster=devnet
// DEVNET

// USDC decimal: 6
// USDC contractAddress:
const String _usdcContractAddress = _useTestnet
    ? '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU'
    : 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

const String _ustContractAddress = _useTestnet
    ? ''
    : 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB';

/// T1 authority, userLT1 mint
const String _testToken2022 = '7qXUiyk7qS7QdtaiGhCmRRRimg6y5EuoSEnJb6x6s3xZ';

Future<void> main() async {
  const from = _user1;
  const to = _user2;

  final generatorFrom = KeyGenerator(mnemonic: from);
  final generatorTo = KeyGenerator(mnemonic: to);
  final pkFrom = await generatorFrom.generateForSolana(forTestnet: _useTestnet);
  final pkTo = await generatorTo.generateForSolana(forTestnet: _useTestnet);
  final addressFrom = pkFrom.publicKey().toAddress();
  final addressTo = pkTo.publicKey().toAddress();

  /// Retrieve the latest block hash.
  final recentBlock = await _rpc.request(
    const SolanaRequestGetLatestBlockhash(),
  );

  // final instructions = <TransactionInstruction>[];

  // ===== Mint start
  final mintAccSpace = SolanaMintAccount.size;
  final rent = await _rpc.request(
    SolanaRequestGetMinimumBalanceForRentExemption(size: mintAccSpace),
  );
  final createAccount = SystemProgram.createAccount(
    from: addressFrom,
    newAccountPubKey: addressTo,
    layout: SystemCreateLayout(
      lamports: rent,
      space: BigInt.from(mintAccSpace),
      programId: SPLTokenProgramConst.token2022ProgramId,
    ),
  );

  final mint = SPLTokenProgram.initializeMint2(
    layout: SPLTokenInitializeMint2Layout(
      mintAuthority: addressFrom,
      decimals: 6,
    ),
    mint: addressTo,
    programId: SPLTokenProgramConst.token2022ProgramId,
  );
  final tx = SolanaTransaction(
    payerKey: addressFrom,
    instructions: [createAccount, mint],
    recentBlockhash: recentBlock.blockhash,
  )..sign([pkFrom, pkTo]);
  // ===== Mint end

  // ====== Mint to (add coins) === Start
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

  // Sign the transaction with the owner's private key.
  final ownerSignature = pkFrom.sign(tx.serializeMessage());
  tx.addSignature(addressFrom, ownerSignature);

  _logger.logInfoMessage('tx ready:', tx.serializeString());
  final simulatedResult = await _rpc.request(
    SolanaRequestSimulateTransaction(
      encodedTransaction: tx.serializeString(),
      sigVerify: false,
    ),
  );

  _logger.logInfoMessage(
    _name,
    'simulatedResultToken: ${simulatedResult.toJson()}',
  );

  // Send the transaction to the Solana network.
  // final res = await _rpc.request(
  //   SolanaRequestSendTransaction(encodedTransaction: tx.serializeString()),
  // );

  // _logger.logInfoMessage(_name, 'TX ID: $res');
}
