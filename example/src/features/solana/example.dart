// example
// ignore_for_file: avoid_redundant_argument_values

import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';
import 'package:tron_energy_wallet_core/src/features/networks/networks.dart';
import 'package:tron_energy_wallet_core/src/features/networks/solana/domain/token_type.dart';

final _logger = InAppLogger()..usePrint = true;
const _name = 'SOLExample';
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
const String _usdcContractAddress = _useTestnet
    ? '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU'
    : 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

const String _ustContractAddress = _useTestnet
    ? ''
    : 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB';

/// T1 authority, userLT1 mint
const String _testToken2022 = '7qXUiyk7qS7QdtaiGhCmRRRimg6y5EuoSEnJb6x6s3xZ';

Future<void> main() async {
  const _amount = '1';
  const from = _user1;
  const to = _user2;
  const String? tokenContract = null;

  final generatorFrom = KeyGenerator(mnemonic: from);
  final generatorTo = KeyGenerator(mnemonic: to);
  final pkFrom = await generatorFrom.generateForSolana(forTestnet: _useTestnet);
  final pkTo = await generatorTo.generateForSolana(forTestnet: _useTestnet);
  final addressFrom = pkFrom.publicKey().toAddress();
  final addressTo = pkTo.publicKey().toAddress();

  await _printBalances(
    wallets: [addressFrom, addressTo],
    contractAddress: tokenContract,
    rpc: _rpc,
    logger: _logger,
  );

  final service = TransactionsServiceSolanaImpl(
    getSigningKey: (_) async => from,
    isTestnet: _useTestnet,
    rpc: _rpc,
  );

  // SPL Token
  final params = tokenContract != null
      ? TransferParamsSOL(
          to: addressTo.address,
          from: addressFrom.address,
          amount: BigRational.parseDecimal(_amount),
          tokenDecimal: 6,
          tokenWalletType: .child,
          usePriorityFee: true, // true/false
          tokenContractAddress: tokenContract,
          // message: 'hi sol',
        )
      : TransferParamsSOL(
          to: addressTo.address,
          from: addressFrom.address,
          amount: BigRational.parseDecimal(_amount),
          tokenDecimal: SolanaUtils.decimal,
          tokenWalletType: .master,
          usePriorityFee: false, // true/false
        );

  final tx = await service.createTransaction(
    params: params,
    masterKey: '',
  );

  // SEND to blockchain
  final res = await _rpc.request(
    SolanaRequestSendTransaction(encodedTransaction: tx),
  );

  _logger.logInfoMessage(_name, 'TX ID: $res');
}

Future<void> _printBalances({
  required List<SolAddress> wallets,
  required SolanaProvider rpc,
  required InAppLogger logger,
  String? contractAddress,
}) async {
  final mintAddress = contractAddress == null
      ? null
      : SolAddress(contractAddress);

  SolTokenType? tokenType;

  if (mintAddress != null) {
    final mintInfo = await _rpc.request(
      SolanaRequestGetAccountInfo(
        account: mintAddress,
        dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
      ),
    );
    tokenType = SolTokenType.fromOwner(mintInfo?.owner);
  }

  for (final wallet in wallets) {
    final bal = await _rpc.request(
      SolanaRequestGetBalance(account: wallet),
    );
    var report = 'wallet: ${wallet.address}, balance: $bal';

    String? balATA;

    if (mintAddress != null && tokenType != null) {
      final walletATA =
          AssociatedTokenAccountProgramUtils.associatedTokenAccount(
            mint: mintAddress,
            owner: wallet,
            tokenProgramId: tokenType.programId,
          );

      final infoATA = await _rpc.request(
        SolanaRequestGetAccountInfo(
          account: walletATA.address,
          dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
        ),
      );

      if (infoATA != null) {
        balATA = (await _rpc.request(
          SolanaRequestGetTokenAccountBalance(
            account: walletATA.address,
            commitment: Commitment.processed,
          ),
        )).amount;
      }
    }
    report += balATA != null
        ? ', token balance: $balATA'
        : ', no ATA for contract $contractAddress';
    logger.logInfoMessage('printBalances', report);
  }
}
