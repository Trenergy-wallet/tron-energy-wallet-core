import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:meta/meta.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/abi/abi.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/optimism_getl1fee.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'transactions_base_impl.dart';
part 'transactions_optimism_impl.dart';

/// Transactions Service
///
/// Provides services for creating and signing ETHEREUM transactions
class TransactionsServiceEthereumImpl
    implements TransactionsService<TransferParamsETH> {
  /// Transactions Service
  ///
  /// Provides services for creating and signing ETHEREUM transactions
  TransactionsServiceEthereumImpl({
    required this.appBlockchain,
    required Future<String> Function(String masterKey) getSigningKey,
    String Function()? getAuthToken,
    this.rpc,
    this.apiUri,
    TRLogger? logger,
  }) : _getAuthToken = getAuthToken,
       _getSigningKey = getSigningKey,
       _onEstimateL1Fee = null,
       assert(
         rpc != null || apiUri != null,
         'Required rpc params are null',
       ),
       assert(
         supportedBlockchains.contains(appBlockchain),
         '$appBlockchain is not supported',
       ) {
    _logger = logger ?? InAppLogger();
    if (appBlockchain.isOptimism || appBlockchain.isBase) {
      assert(
        _onEstimateL1Fee != null,
        'onEstimateL1Fee is required. Consider using local implementation like '
        'TransactionsServiceOptimismImpl',
      );
    }
  }

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain;

  /// Node provider
  final EthereumProvider? rpc;

  /// Ethereum API address
  final String? apiUri;

  /// Auth token for the backend
  final String Function()? _getAuthToken;

  /// Get Tron private key as String
  final Future<String> Function(String masterKey) _getSigningKey;

  String get _name => 'TransactionsServiceEthereumImpl-${appBlockchain.slug}';

  late final TRLogger _logger;

  EthereumProvider get _ethereumProvider =>
      rpc ??
      EthereumProvider(
        EthereumHTTPProvider(
          apiUri!,
          _getAuthToken?.call(),
        ),
      );

  /// Supported blockchains by this service
  static const List<AppBlockchain> supportedBlockchains = [
    AppBlockchain.ethereum,
    AppBlockchain.bsc,
    AppBlockchain.arbitrum,
    AppBlockchain.polygon,
    AppBlockchain.optimism,
    AppBlockchain.base,
  ];

  /// Estimates the L1 fee in wei (if applicable)
  final Future<BigInt> Function(ETHTransaction transaction)? _onEstimateL1Fee;

  /// We increase the fee with a buffer/multiplier to improve the chance of
  /// inclusion if conditions change while the tx is pending in the mempool
  ///
  /// The syntax is correct, this is exactly how BigInt calculations should be
  /// done
  @visibleForTesting
  BigInt applyEIP1559FeeBufferMultiplier(BigInt value) =>
      switch (appBlockchain) {
        .bsc => value * BigInt.from(6) ~/ BigInt.from(5),
        .arbitrum || .polygon => value * BigInt.two,
        _ => value * BigInt.from(3) ~/ BigInt.from(2),
      };

  /// We increase the fee with a buffer/multiplier to improve the chance of
  /// inclusion if conditions change while the tx is pending in the mempool
  ///
  /// The syntax is correct, this is exactly how BigInt calculations should be
  /// done
  @visibleForTesting
  BigInt applyLegacyFeeBufferMultiplier(BigInt value) =>
      switch (appBlockchain) {
        .ethereum => value * BigInt.from(11) ~/ BigInt.from(10),
        .bsc => value * BigInt.from(6) ~/ BigInt.from(5),
        .arbitrum => value * BigInt.two,
        _ => value * BigInt.from(3) ~/ BigInt.from(2),
      };

  /// Create signed transaction for Ethereum or compatible token
  @override
  Future<String> createTransaction({
    required TransferParamsETH params,
    required String masterKey,
  }) async {
    if (!supportedBlockchains.contains(params.appBlockchain)) {
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
    final tx = await _tryCreateTransaction(
      params: params,
    );
    if (params.userApprovedFee != null) {
      final userApproved = ETHHelper.toWei(
        params.userApprovedFee!.fee.toString(),
      );
      final feeInWei = switch (tx.transactionType) {
        ETHTransactionType.eip1559 => tx.maxFeePerGas! * tx.gasLimit,
        _ => tx.gasPrice! * tx.gasLimit,
      };
      final parsedFeeBuffer = BigRational.parseDecimal(
        '${params.approvedFeeBuffer}',
      );
      _logger.logInfoMessage(
        _name,
        'createTransactionOrThrow: feeInWei: $feeInWei '
        '(maxFeePerGas: ${tx.maxFeePerGas}, '
        'gasPrice: ${tx.gasPrice}, gasLimit: ${tx.gasLimit}), '
        'user approved: $userApproved, parsedFeeBuffer: $parsedFeeBuffer',
      );
      if (feeInWei >
          (userApproved *
              parsedFeeBuffer.numerator ~/
              parsedFeeBuffer.denominator)) {
        throw AppFeeChangedException(
          params.userApprovedFee!,
          EstimateFeeModel.empty.copyWith(
            fee: double.parse(ETHHelper.fromWei(feeInWei)),
          ),
        );
      }
    }
    return _trySignTransaction(tx: tx, masterKey: masterKey);
  }

  /// Create the transaction for the main coin of the blockchain (ex-Ethereum)
  @visibleForTesting
  Future<ETHTransaction> buildTransaction({
    required EthereumProvider rpc,
    required TransferParamsETH params,
    required int nonce,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
  }) async {
    ETHTransaction? tx;
    if (params.supportsEIP1559 && eip1559Fee != null) {
      _logger.logInfoMessage(
        _name,
        'Creating eip1559Fee transaction to ${params.to}, '
        'amount: ${params.amount}',
      );
      final selectedFee = switch (params.feeType) {
        FeeType.economy => eip1559Fee.slow,
        FeeType.optimal => eip1559Fee.normal,
        FeeType.fast => eip1559Fee.high,
      };
      // Arbitrum uses a sequencer, so we add a safety buffer
      final maxFeePerGas = applyEIP1559FeeBufferMultiplier(
        selectedFee + eip1559Fee.baseFee,
      );
      tx = ETHTransaction(
        type: ETHTransactionType.eip1559,
        from: ETHAddress(params.from),
        to: ETHAddress(params.to),
        nonce: nonce,
        gasLimit: BigInt.zero,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: selectedFee,
        data: [
          if (params.message != null && params.message!.isNotEmpty)
            ...StringUtils.toBytes(params.message!),
        ],
        value: ETHHelper.toWei(params.amount.toString()),
        chainId: BigInt.from(params.chainId),
      );
    } else {
      if (params.supportsEIP1559) {
        _logger.logInfoMessage(
          _name,
          'No EIP1559 fee provided, switching to legacy mode',
        );
      }
      if (gasPrice == null) {
        throw AppException(
          message: 'gasPrice is not provided for legacy transaction',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }
      gasPrice = applyLegacyFeeBufferMultiplier(gasPrice);
      tx = ETHTransaction(
        type: ETHTransactionType.legacy,
        from: ETHAddress(params.from),
        to: ETHAddress(params.to),
        nonce: nonce,
        gasLimit: BigInt.zero,
        // Only for legacy and eip2930 transactions
        gasPrice: gasPrice,
        data: [
          if (params.message != null && params.message!.isNotEmpty)
            ...StringUtils.toBytes(params.message!),
        ],
        value: ETHHelper.toWei(params.amount.toString()),
        chainId: BigInt.from(params.chainId),
      );
    }
    var gasLimit = await rpc.request(
      EthereumRequestEstimateGas(transaction: tx.toEstimate()),
    );
    // Adding safety buffer
    gasLimit = gasLimit * BigInt.from(11) ~/ BigInt.from(10);
    tx = tx.copyWith(gasLimit: gasLimit);
    _logger.logInfoMessage(_name, 'tx ready: ${tx.toJson()}');
    return tx;
  }

  /// Create the transaction for ERC-20 token
  @visibleForTesting
  Future<ETHTransaction> buildERC20Transaction({
    required EthereumProvider rpc,
    required TransferParamsETH params,
    required int nonce,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
  }) async {
    ETHTransaction? tx;
    if (params.tokenContractAddress == null) {
      throw AppException(
        message: 'Token contract is null',
        code: ExceptionCode.unableToCreateTransaction,
      );
    }
    if (params.supportsEIP1559 && eip1559Fee != null) {
      _logger.logInfoMessage(
        _name,
        'Creating eip1559Fee ERC20 transaction to ${params.to}, '
        'amount: ${params.amount}${params.tokenName != null ? ', '
                  'token: ${params.tokenName}' : ''}',
      );
      final selectedFee = switch (params.feeType) {
        FeeType.economy => eip1559Fee.slow,
        FeeType.optimal => eip1559Fee.normal,
        FeeType.fast => eip1559Fee.high,
      };

      final maxFeePerGas = applyEIP1559FeeBufferMultiplier(
        selectedFee + eip1559Fee.baseFee,
      );
      tx = ETHTransaction(
        type: ETHTransactionType.eip1559,
        from: ETHAddress(params.from),
        to: ETHAddress(params.tokenContractAddress!),
        nonce: nonce,
        gasLimit: BigInt.zero,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: selectedFee,
        data: ethTransferAbiFragment.encode([
          ETHAddress(params.to),
          DecimalConverter.toBigInt(
            amount: params.amount.toString(),
            decimals: params.tokenDecimal,
          ),
        ]),
        value: BigInt.zero,
        chainId: BigInt.from(params.chainId),
      );
    } else {
      if (params.supportsEIP1559) {
        _logger.logInfoMessage(
          _name,
          'No EIP1559 fee provided, switching to legacy mode',
        );
      }
      if (gasPrice == null) {
        throw AppException(
          message: 'gasPrice is not provided for legacy transaction',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }
      gasPrice = applyLegacyFeeBufferMultiplier(gasPrice);
      tx = ETHTransaction(
        type: ETHTransactionType.legacy,
        from: ETHAddress(params.from),
        to: ETHAddress(params.tokenContractAddress!),
        nonce: nonce,
        gasLimit: BigInt.zero,
        gasPrice: gasPrice,
        data: ethTransferAbiFragment.encode([
          ETHAddress(params.to),
          DecimalConverter.toBigInt(
            amount: params.amount.toString(),
            decimals: params.tokenDecimal,
          ),
        ]),
        value: BigInt.zero,
        chainId: BigInt.from(params.chainId),
      );
    }
    var gasLimit = await rpc.request(
      EthereumRequestEstimateGas(transaction: tx.toEstimate()),
    );
    // Adding safety buffer
    gasLimit = gasLimit * BigInt.from(11) ~/ BigInt.from(10);
    tx = tx.copyWith(gasLimit: gasLimit);
    _logger.logInfoMessage(_name, 'tx ready: ${tx.toJson()}');
    return tx;
  }

  @override
  Future<bool> checkWalletIsFrozen({
    required String assetAddress,
    required String addressToCheck,
  }) async => false;

  /// Estimate gas fee for the dummy transaction
  ///
  /// [CoreConsts.defaultEthFeeType] = default for ETH
  Future<String> tryEstimateFee({
    required TransferParamsETH params,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
  }) async {
    final tx = await _tryCreateTransaction(
      params: params,
      gasPrice: gasPrice,
      eip1559Fee: eip1559Fee,
      forceUpdateNonce: false,
    );
    final l1fee = await _onEstimateL1Fee?.call(tx) ?? BigInt.zero;
    final feeInWei =
        switch (tx.transactionType) {
          ETHTransactionType.eip1559 => tx.maxFeePerGas! * tx.gasLimit,
          _ => tx.gasPrice! * tx.gasLimit,
        } +
        l1fee;
    _logger.logInfoMessage(
      _name,
      'tryEstimateFee: $feeInWei (maxFeePerGas: ${tx.maxFeePerGas}, '
      'gasPrice: ${tx.gasPrice}, gasLimit: ${tx.gasLimit}, l1fee: $l1fee)',
    );
    return ETHHelper.fromWei(feeInWei);
  }

  /// Gas price for legacy transaction
  Future<BigInt> tryGetGasPrice() async =>
      _ethereumProvider.request(EthereumRequestGetGasPrice());

  /// Gas price for Eip1559 transaction
  Future<FeeHistorical> tryGetEip1559Fee() async {
    final eip1559Historical = await _ethereumProvider.request(
      EthereumRequestGetFeeHistory(
        blockCount: CoreConsts.ethBlockCountForFee,
        newestBlock: BlockTagOrNumber.pending,
        rewardPercentiles: CoreConsts.ethRewardPercentilesForFee,
      ),
    );
    return eip1559Historical!.toFee();
  }

  @override
  Future<({String address, List<int> pkAsBytes})> initializeWalletAndGetInfo({
    required String masterKey,
  }) async {
    final pk = await _createSigningKey(masterKey: masterKey);
    return (
      address: pk.publicKey().toAddress().address,
      pkAsBytes: pk.toBytes(),
    );
  }

  /// Create a signing key for Ethereum
  ///
  /// THROWS
  Future<ETHPrivateKey> _createSigningKey({
    required String masterKey,
  }) async {
    final mnemonic = await _getSigningKey(masterKey);
    if (mnemonic.isEmpty) {
      throw AppException(code: ExceptionCode.unableToRetrieveMnemonic);
    }
    return KeyGenerator(mnemonic: mnemonic).generateForEthereum();
  }

  /// Create transaction for Ethereum or compatible token
  ///
  /// [forceUpdateNonce] - do not use cached nonce
  Future<ETHTransaction> _tryCreateTransaction({
    required TransferParamsETH params,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
    bool forceUpdateNonce = true,
  }) async {
    if (params.amount < BigRational.zero) {
      throw AppException(
        message:
            'unable to create transaction: amount is not positive: '
            '${params.amount}',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    final nonce = await _ethereumProvider.request(
      EthereumRequestGetTransactionCount(address: params.from),
    );

    if (params.supportsEIP1559) {
      eip1559Fee ??= await tryGetEip1559Fee();
    } else {
      gasPrice ??= await tryGetGasPrice();
    }

    return params.tokenWalletType.isMaster
        ? await buildTransaction(
            rpc: _ethereumProvider,
            params: params,
            nonce: nonce,
            gasPrice: gasPrice,
            eip1559Fee: eip1559Fee,
          )
        // Memo is not supported for standard ERC20 contracts
        : await buildERC20Transaction(
            rpc: _ethereumProvider,
            params: params,
            nonce: nonce,
            gasPrice: gasPrice,
            eip1559Fee: eip1559Fee,
          );
  }

  Future<String> _trySignTransaction({
    required ETHTransaction tx,
    required String masterKey,
  }) async {
    final pk = await _createSigningKey(masterKey: masterKey);

    // Get transaction digest and sign with private key
    final sign = pk.sign(tx.serialized);

    /// Serialize the signed transaction
    final signedSerialized = BytesUtils.toHexString(
      tx.signedSerialized(sign),
      prefix: '0x',
    );
    return signedSerialized;
  }
}
