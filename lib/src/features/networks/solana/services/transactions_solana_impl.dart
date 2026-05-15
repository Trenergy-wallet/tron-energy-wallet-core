import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:meta/meta.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service
///
/// Provides services for creating and signing SOLANA transactions
class TransactionsServiceSolanaImpl
    implements TransactionsService<TransferParamsSOL> {
  /// Transactions Service
  ///
  /// Provides services for creating and signing SOLANA transactions
  TransactionsServiceSolanaImpl({
    required Future<String> Function(String masterKey) getSigningKey,
    required this.isTestnet,
    String Function()? getAuthToken,
    this.rpc,
    this.apiUri,
    TRLogger? logger,
  }) : appBlockchain = AppBlockchain.solana,
       _getAuthToken = getAuthToken,
       _getSigningKey = getSigningKey,
       assert(
         rpc != null || apiUri != null,
         'Required rpc params are null',
       ) {
    _logger = logger ?? InAppLogger();
  }

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain;

  /// Node provider
  final SolanaProvider? rpc;

  /// Solana API address
  final String? apiUri;

  /// Auth token for the backend
  final String Function()? _getAuthToken;

  /// Get Tron private key as String
  final Future<String> Function(String masterKey) _getSigningKey;

  String get _name => 'TransactionsServiceSolanaImpl';

  late final TRLogger _logger;

  /// Testnet params (impact on address generation)
  final bool isTestnet;

  SolanaProvider get _nodeProvider =>
      rpc ??
      SolanaProvider(
        SolanaHTTPProvider(
          url: apiUri!,
          authToken: _getAuthToken?.call(),
        ),
      );

  /// Create signed transaction for Solana
  @override
  Future<String> createTransaction({
    required TransferParamsSOL params,
    required String masterKey,
  }) async {
    if (!params.appBlockchain.isSolana) {
      throw AppException(
        message: 'Blockchain is not supported: ${params.appBlockchain}',
        code: ExceptionCode.blockchainIsNotSupported,
      );
    }
    if (params.amount <= BigRational.zero) {
      throw AppException(
        message:
            'unable to create transaction: amount is not valid: '
            '${params.amount}',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    final tx = await _tryCreateTransaction(params: params);
    await _trySignTransaction(
      tx: tx,
      masterKey: masterKey,
      owner: params.fromSolAddress,
    );
    final simulatedResult = await _nodeProvider.request(
      SolanaRequestSimulateTransaction(
        encodedTransaction: tx.serializeString(),
        sigVerify: false,
      ),
    );

    if (simulatedResult.err != null) {
      throw AppException(
        code: ExceptionCode.unableToCreateTransaction,
        message: simulatedResult.err.toString(),
      );
    }
    _logger.logInfoMessage(
      _name,
      'simulatedResult: ${simulatedResult.toJson()}',
    );
    return tx.serializeString();
  }

  /// Create the transaction for the main coin of the blockchain
  @visibleForTesting
  Future<SolanaTransaction> buildTransaction({
    required SolanaProvider rpc,
    required TransferParamsSOL params,
  }) async {
    /// Retrieve the latest block hash.
    final recentBlock = await _nodeProvider.request(
      const SolanaRequestGetLatestBlockhash(),
    );
    // final amountToSend = bal1 - _baseFeeLamports.toBigInt;
    // final amountToSend = SolanaUtils.toLamports('0.1);
    /// Create a transfer instruction to move funds from the owner to the receiver.
    final transferInstruction = SystemProgram.transfer(
      from: params.fromSolAddress,
      layout: SystemTransferLayout(lamports: params.amount.toBigInt()),
      to: params.toSolAddress,
    );

    final tx = SolanaTransaction(
      payerKey: params.fromSolAddress,
      instructions: [transferInstruction],
      recentBlockhash: recentBlock.blockhash,
      type: TransactionType.v0,
    );
    _logger.logInfoMessage(_name, 'tx ready: ${tx.serializeString()}');
    return tx;
  }

  /// Create the transaction for SPL token
  @visibleForTesting
  Future<SolanaTransaction> buildSplTokenTransaction({
    required SolanaProvider rpc,
    required TransferParamsSOL params,
  }) async {
    final mintAddress = params.tokenContractAddressSolAddress;
    if (mintAddress == null) {
      throw AppException(
        message: 'Token contract is null',
        code: ExceptionCode.unableToCreateTransaction,
      );
    }

    /// Retrieve the latest block hash.
    final recentBlock = await _nodeProvider.request(
      const SolanaRequestGetLatestBlockhash(),
    );

    final instructions = <TransactionInstruction>[];
    // 1. Вычисляем ATA (Associated Token Account) для отправителя и получателя
    // Используем утилиту из вашего файла create_associated_token_account.dart
    final sourceATA = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
      mint: mintAddress,
      owner: params.fromSolAddress,
    );

    final sendInfo = await _nodeProvider.request(
      SolanaRequestGetAccountInfo(account: sourceATA.address),
    );
    _logger.logInfoMessage(_name, 'sendInfo: ${sendInfo?.toJson()}');

    final destinationATA =
        AssociatedTokenAccountProgramUtils.associatedTokenAccount(
          mint: mintAddress,
          owner: params.toSolAddress,
        );

    // Destination exists?
    final destinationInfo = await _nodeProvider.request(
      SolanaRequestGetAccountInfo(account: destinationATA.address),
    );

    _logger.logInfoMessage(
      _name,
      'destinationInfo: ${destinationInfo?.toJson()}',
    );

    // If the account doesn't exist, add the creation instruction
    if (destinationInfo == null) {
      instructions.add(
        AssociatedTokenAccountProgram.associatedTokenAccount(
          payer: params.fromSolAddress,
          associatedToken: destinationATA.address,
          owner: params.toSolAddress,
          mint: mintAddress,
        ),
      );
    }

    // 4. Add the SPL Token transfer instruction
    instructions.add(
      SPLTokenProgram.transfer(
        source: sourceATA.address,
        destination: destinationATA.address,
        owner: params.fromSolAddress,
        layout: SPLTokenTransferLayout(
          amount: DecimalConverter.toBigInt(
            amount: params.amount.toString(),
            decimals: params.tokenDecimal,
          ),
        ),
      ),
    );

    final tx = SolanaTransaction(
      payerKey: params.fromSolAddress,
      instructions: instructions,
      recentBlockhash: recentBlock.blockhash,
      type: TransactionType.v0,
    );

    _logger.logInfoMessage(_name, 'tx ready: ${tx.serializeString()}');
    return tx;
  }

  @override
  Future<bool> checkWalletIsFrozen({
    required String assetAddress,
    required String addressToCheck,
  }) async => false;

  @override
  Future<({String address, List<int> pkAsBytes})> initializeWalletAndGetInfo({
    required String masterKey,
  }) async {
    final pk = await _createSigningKey(masterKey: masterKey);
    return (
      address: pk.publicKey().toAddress().address,
      pkAsBytes: pk.seedBytes(),
    );
  }

  /// Create a signing key for Solana
  ///
  /// THROWS
  Future<SolanaPrivateKey> _createSigningKey({
    required String masterKey,
  }) async {
    final mnemonic = await _getSigningKey(masterKey);
    if (mnemonic.isEmpty) {
      throw AppException(code: ExceptionCode.unableToRetrieveMnemonic);
    }
    return KeyGenerator(
      mnemonic: mnemonic,
    ).generateForSolana(forTestnet: isTestnet);
  }

  /// Create transaction for Solana or compatible SPL token
  Future<SolanaTransaction> _tryCreateTransaction({
    required TransferParamsSOL params,
  }) async {
    if (params.amount < BigRational.zero) {
      throw AppException(
        message:
            'unable to create transaction: amount is not positive: '
            '${params.amount}',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    // TODO(ivn): Program check?
    return params.tokenWalletType.isMaster
        ? await buildTransaction(
            rpc: _nodeProvider,
            params: params,
          )
        : await buildSplTokenTransaction(
            rpc: _nodeProvider,
            params: params,
          );
  }

  Future<void> _trySignTransaction({
    required SolanaTransaction tx,
    required SolAddress owner,
    required String masterKey,
  }) async {
    final pk = await _createSigningKey(masterKey: masterKey);
    final ownerSignature = pk.sign(tx.serializeMessage());
    tx.addSignature(owner, ownerSignature);
    return;
  }
}
