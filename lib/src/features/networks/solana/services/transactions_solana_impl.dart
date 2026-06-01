// linter bug
// ignore_for_file: parameter_assignments

import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:meta/meta.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/solana/domain/token_type.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _priorityFeeOnError = 5000;
const _minPriorityFee = 2000;
const _maxPriorityFee = 2000000;

// https://docs.chainstack.com/docs/solana-compute-budget
const _buildInInstructionCuLimit = 3000;

/// Transactions Service
///
/// Provides services for creating and signing SOLANA transactions
class TransactionsServiceSolanaImpl
    implements TransactionsService<TransferParamsSOL> {
  /// Transactions Service
  ///
  /// Provides services for creating and signing SOLANA transactions
  ///
  /// [getPriorityFeePricePerUnit] - default is non-zero medium calculation
  TransactionsServiceSolanaImpl({
    required Future<String> Function(String masterKey) getSigningKey,
    required this.isTestnet,
    String Function()? getAuthToken,
    Future<int> Function(List<SolAddress> addresses)?
    getPriorityFeePricePerUnit,
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
    _getPriorityFeePricePerUnit =
        getPriorityFeePricePerUnit ?? _getPriorityFeePricePerUnitDefault;
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

  late final Future<int> Function(List<SolAddress> addresses)
  _getPriorityFeePricePerUnit;

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
    if (!params.finalized) {
      params = await calculatePriorityFee(params);
    }
    if (!params.finalized) {
      _logger.logError(
        _name,
        'createTransaction: Cannot finalize priority fee params.'
        ' Skipping the priority fee',
      );
      params = params.copyWith(usePriorityFee: false);
    }
    _logger.logInfoMessage(
      _name,
      'Start building the tx with usePriorityFee=${params.usePriorityFee}',
    );
    final tx = await _tryCreateTransaction(
      params: params,
      simulatePriorityFee: false,
    );
    final signedTx = await _trySignTransaction(
      tx: tx.tx,
      masterKey: masterKey,
      owner: params.solAddressFrom,
    );
    return signedTx.serializeString();
  }

  /// Create the transaction for the main coin of the blockchain
  @visibleForTesting
  Future<SolanaTransaction> buildTransaction({
    required SolanaProvider rpc,
    required TransferParamsSOL params,
    required bool simulatePriorityFee,
  }) async {
    /// Retrieve the latest block hash.
    final blockHash = await _getTransactionBlockHash(
      simulate: simulatePriorityFee,
    );
    final amountToSend = DecimalConverter.toBigInt(
      amount: params.amount.toString(),
      decimals: params.tokenDecimal,
    );

    _logger.logInfoMessage(
      _name,
      'buildTransaction: will send $amountToSend, from '
      '${params.solAddressFrom}, to: ${params.solAddressTo}',
    );

    /// Create a transfer instruction to move funds from the owner to
    /// the receiver
    final transferInstruction = SystemProgram.transfer(
      from: params.solAddressFrom,
      layout: SystemTransferLayout(lamports: amountToSend),
      to: params.solAddressTo,
    );

    final tx = SolanaTransaction(
      payerKey: params.solAddressFrom,
      instructions: [
        if (simulatePriorityFee)
          SolanaHelper.createLimitInstruction(1400000)
        else if (params.usePriorityFee &&
            params.cuLimit > 0 &&
            params.priorityFeeMicrolamports > 0) ...[
          SolanaHelper.createLimitInstruction(params.cuLimit),
          SolanaHelper.createPriceInstruction(
            params.priorityFeeMicrolamports.toBigInt,
          ),
        ],
        transferInstruction,
        if (params.message != null && params.message!.isNotEmpty)
          SolanaHelper.createMemoInstruction(params.message!),
      ],
      recentBlockhash: blockHash,
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
    required bool simulatePriorityFee,
  }) async {
    final mintAddress = params.tokenContractAddressSolAddress;
    if (mintAddress == null) {
      throw AppException(
        message: 'Token contract is null',
        code: ExceptionCode.unableToCreateTransaction,
      );
    }
    if (params.tokenType.isUnknown) {
      final mintInfo = await _nodeProvider.request(
        SolanaRequestGetAccountInfo(
          account: mintAddress,
          dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
        ),
      );

      final tokenType = SolTokenType.fromOwner(mintInfo?.owner);
      params = params.copyWith(tokenType: tokenType);
      if (params.tokenType.isUnknown) {
        throw AppException(
          message: 'buildSplTokenTransaction: unknown token type',
          code: .wrongToken,
        );
      }
    }

    /// Retrieve the latest block hash
    final blockHash = await _getTransactionBlockHash(
      simulate: simulatePriorityFee,
    );

    final instructions = <TransactionInstruction>[
      if (simulatePriorityFee)
        SolanaHelper.createLimitInstruction(1400000)
      else if (params.usePriorityFee &&
          params.cuLimit > 0 &&
          params.priorityFeeMicrolamports > 0) ...[
        SolanaHelper.createLimitInstruction(params.cuLimit),
        SolanaHelper.createPriceInstruction(
          params.priorityFeeMicrolamports.toBigInt,
        ),
      ],
    ];
    // 1. Find ATA (Associated Token Account) for the sender
    final sourceATA = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
      mint: mintAddress,
      owner: params.solAddressFrom,
      tokenProgramId: params.tokenType.programId,
    );

    // 2. Find ATA (Associated Token Account) for the destination
    final destinationATA =
        AssociatedTokenAccountProgramUtils.associatedTokenAccount(
          mint: mintAddress,
          owner: params.solAddressTo,
          tokenProgramId: params.tokenType.programId,
        );

    // 3. Destination ATA account exists?
    final destinationInfo = await _nodeProvider.request(
      SolanaRequestGetAccountInfo(
        account: destinationATA.address,
        // Lightweight account existence check
        dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
      ),
    );

    _logger.logInfoMessage(
      _name,
      'destinationInfo: ${destinationInfo?.toJson()}',
    );

    // 4. If the account doesn't exist, add the creation instruction
    if (destinationInfo == null) {
      instructions.add(
        AssociatedTokenAccountProgram.associatedTokenAccount(
          payer: params.solAddressFrom,
          associatedToken: destinationATA.address,
          owner: params.solAddressTo,
          mint: mintAddress,
          tokenProgramId: params.tokenType.programId,
        ),
      );
    }

    // 5. Add the SPL Token transfer instruction depending on the tokenType
    switch (params.tokenType) {
      case .splToken:
        instructions.add(
          SPLTokenProgram.transfer(
            source: sourceATA.address,
            destination: destinationATA.address,
            owner: params.solAddressFrom,
            programId: params.tokenType.programId,
            layout: SPLTokenTransferLayout(
              amount: DecimalConverter.toBigInt(
                amount: params.amount.toString(),
                decimals: params.tokenDecimal,
              ),
            ),
          ),
        );
      case .splToken2022:
        instructions.add(
          SPLTokenProgram.transferChecked(
            layout: SPLTokenTransferCheckedLayout(
              amount: DecimalConverter.toBigInt(
                amount: params.amount.toString(),
                decimals: params.tokenDecimal,
              ),
              decimals: params.tokenDecimal,
            ),
            owner: params.solAddressFrom,
            source: sourceATA.address,
            mint: mintAddress,
            destination: destinationATA.address,
            programId: params.tokenType.programId,
          ),
        );
      case .unknown:
        throw AppException(message: 'Unknown token type', code: .wrongToken);
    }

    if (params.message != null && params.message!.isNotEmpty) {
      instructions.add(SolanaHelper.createMemoInstruction(params.message!));
    }

    final tx = SolanaTransaction(
      payerKey: params.solAddressFrom,
      instructions: instructions,
      recentBlockhash: blockHash,
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

  /// Calculate PriorityFee and add it to the params
  Future<TransferParamsSOL> calculatePriorityFee(
    TransferParamsSOL params,
  ) async {
    final addresses = <SolAddress>[];
    switch (params.tokenWalletType) {
      case .master:
        addresses.addAll([
          params.solAddressTo,
          params.solAddressFrom,
        ]);
      case .child:
      case .stable:
        final mintAddress = params.tokenContractAddressSolAddress;
        if (mintAddress == null) {
          throw AppException(
            code: .unableToCreateTransaction,
            message: 'calculatePriorityFee: Mint address is null',
          );
        }
        if (params.tokenType.isUnknown) {
          final mintInfo = await _nodeProvider.request(
            SolanaRequestGetAccountInfo(
              account: mintAddress,
              dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
            ),
          );
          final tokenType = SolTokenType.fromOwner(mintInfo?.owner);
          _logger.logInfoMessage(
            _name,
            'calculatePriorityFee: token type detected: $tokenType',
          );
          params = params.copyWith(tokenType: tokenType);
          if (params.tokenType.isUnknown) {
            throw AppException(
              message: 'buildSplTokenTransaction: unknown token type',
              code: .wrongToken,
            );
          }
        }
        final sourceATA =
            AssociatedTokenAccountProgramUtils.associatedTokenAccount(
              mint: mintAddress,
              owner: params.solAddressFrom,
              programId: params.tokenType.programId,
            );
        final destinationATA =
            AssociatedTokenAccountProgramUtils.associatedTokenAccount(
              mint: mintAddress,
              owner: params.solAddressTo,
              programId: params.tokenType.programId,
            );
        final destinationATAExists = await accountExists(
          destinationATA.address.address,
        );

        addresses.addAll([
          mintAddress,
          sourceATA.address,
          destinationATA.address,
          if (!destinationATAExists) params.solAddressFrom,
        ]);
      case .unknown:
        throw AppException(
          code: .unableToCreateTransaction,
          message: 'tokenWalletType is unknown',
        );
    }
    final priorityFeePricePerUnit = await _getPriorityFeePricePerUnit(
      addresses,
    );
    final unitsConsumed = await _tryCreateTransaction(
      params: params,
      simulatePriorityFee: true,
      addresses: addresses,
    );
    final unitsWithGap =
        (unitsConsumed.simulated.unitsConsumed?.toInt() ?? 0) * 12 ~/ 10 +
        // Add a limit for the createPriceInstruction
        _buildInInstructionCuLimit;
    return params.copyWith(
      priorityFeeMicrolamports: priorityFeePricePerUnit,
      cuLimit: unitsWithGap,
    );
  }

  Future<int> _getPriorityFeePricePerUnitDefault(
    List<SolAddress> addresses,
  ) async {
    try {
      final feePrices = await _nodeProvider.request(
        SolanaRequestGetRecentPrioritizationFees(addresses: addresses),
      );
      final nonZeroFees = feePrices
          .map((e) => e.prioritizationFee)
          .where((fee) => fee > 0)
          .toList();

      if (nonZeroFees.isEmpty) return _minPriorityFee;
      nonZeroFees.sort();
      var selectedFee = _minPriorityFee;
      final medianFee = nonZeroFees[nonZeroFees.length ~/ 2];
      selectedFee = medianFee.clamp(_minPriorityFee, _maxPriorityFee);
      _logger.logInfoMessage(
        _name,
        'getPriorityFeePricePerUnit: median: $medianFee, '
        'selected: $selectedFee',
      );
      return selectedFee;
    } catch (e) {
      _logger.logError(
        _name,
        'getPriorityFeePricePerUnit: using $_priorityFeeOnError got '
        'ERROR: $e',
      );
      return _priorityFeeOnError;
    }
  }

  /// MinimumBalance for the account
  Future<BigInt> getMinimumBalanceForRentExemption(
    TokenWalletType type,
  ) async => _nodeProvider.request(
    SolanaRequestGetMinimumBalanceForRentExemption(
      // 165 is the solana blockchain constant size for the ATA SPL-token
      size: type.isMaster ? 0 : 165,
    ),
  );

  /// Check account for the existence
  Future<bool> accountExists(String address) async {
    final info = await _nodeProvider.request(
      SolanaRequestGetAccountInfo(
        account: SolAddress.unchecked(address),
        // Lightweight account existence check
        dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
      ),
    );
    return info != null;
  }

  /// SPL ATA Address for token ontract
  Future<String> getATAAddressForTokenContract({
    required String solWalletAddress,
    required String tokenContractAddress,
  }) async {
    final mintAddress = SolAddress(tokenContractAddress);
    final mintInfo = await _nodeProvider.request(
      SolanaRequestGetAccountInfo(
        account: mintAddress,
        dataSlice: const RPCDataSliceConfig(length: 0, offset: 0),
      ),
    );
    final tokenType = SolTokenType.fromOwner(mintInfo?.owner);

    return AssociatedTokenAccountProgramUtils.associatedTokenAccount(
      mint: mintAddress,
      owner: SolAddress.unchecked(solWalletAddress),
      tokenProgramId: tokenType.programId,
    ).address.address;
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
  Future<({SimulateTranasctionResponse simulated, SolanaTransaction tx})>
  _tryCreateTransaction({
    required TransferParamsSOL params,
    required bool simulatePriorityFee,
    List<SolAddress> addresses = const [],
  }) async {
    if (params.amount < BigRational.zero) {
      throw AppException(
        message:
            'unable to create transaction: amount is not positive: '
            '${params.amount}',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    final tx = params.tokenWalletType.isMaster
        ? await buildTransaction(
            rpc: _nodeProvider,
            params: params,
            simulatePriorityFee: simulatePriorityFee,
          )
        : await buildSplTokenTransaction(
            rpc: _nodeProvider,
            params: params,
            simulatePriorityFee: simulatePriorityFee,
          );
    final simulatedResult = await _nodeProvider.request(
      SolanaRequestSimulateTransaction(
        encodedTransaction: tx.serializeString(),
        replaceRecentBlockhash: simulatePriorityFee,
        sigVerify: false,
        accounts: addresses.isNotEmpty
            ? RPCAccountConfig(
                addresses: addresses,
                encoding: SolanaRequestEncoding.base64,
              )
            : null,
      ),
    );

    if (simulatedResult.err != null) {
      throw AppException(
        code: ExceptionCode.unableToCreateTransaction,
        message: simulatedResult.toJson().toString(),
      );
    }
    _logger.logInfoMessage(
      _name,
      'simulatedResult: ${simulatedResult.toJson()}',
    );
    return (tx: tx, simulated: simulatedResult);
  }

  Future<SolanaTransaction> _trySignTransaction({
    required SolanaTransaction tx,
    required SolAddress owner,
    required String masterKey,
  }) async {
    final pk = await _createSigningKey(masterKey: masterKey);
    final ownerSignature = pk.sign(tx.serializeMessage());
    tx.addSignature(owner, ownerSignature);
    return tx;
  }

  Future<SolAddress> _getTransactionBlockHash({bool simulate = false}) async {
    if (simulate) return SolAddress.defaultPubKey;
    final blockHash = await _nodeProvider.request(
      const SolanaRequestGetLatestBlockhash(),
    );
    return blockHash.blockhash;
  }
}
