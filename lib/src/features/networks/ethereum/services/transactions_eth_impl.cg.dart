import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:meta/meta.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/abi/abi.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/optimism_getl1fee.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'transactions_optimism_impl.dart';

/// Transactions Service
///
/// Provides services for creating and signing ETHEREUM transactions
class TransactionsServiceEthereumImpl implements TransactionsService {
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
    if (appBlockchain.isOptimism) {
      assert(
        _onEstimateL1Fee != null,
        'onEstimateL1Fee is required for Optimism. Consider using '
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
  ];

  /// Estimates the L1 fee in wei (if applicable)
  final Future<BigInt> Function(ETHTransaction transaction)? _onEstimateL1Fee;

  /// We increase the fee with a buffer/multiplier to improve the chance of
  /// inclusion if conditions change while the tx is pending in the mempool
  ///
  /// The syntax is correct, this is exactly how BigInt calculations should be
  /// done
  @visibleForTesting
  BigInt applyBufferMultiplier(BigInt value) => switch (appBlockchain) {
    AppBlockchain.bsc => value * BigInt.from(6) ~/ BigInt.from(5),
    AppBlockchain.arbitrum => value * BigInt.two,
    AppBlockchain.polygon => value * BigInt.two,
    _ => value * BigInt.from(3) ~/ BigInt.from(2),
  };

  /// Create signed transaction for Ethereum or compatible token
  @override
  Future<String> createTransaction({
    required String toAddress,
    required BigRational amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    FeeType? feeType,
    EstimateFeeModel? userApprovedFee,
    String? txIdToPumpFeeBTC,
  }) async {
    if (amount <= BigRational.zero) {
      throw AppException(
        message: 'unable to create transaction: amount is not valid: $amount',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    final tx = await _tryCreateTransaction(
      toAddress: toAddress,
      amount: amount,
      asset: asset,
      message: message,
      feeType: feeType,
      userApprovedFee: userApprovedFee,
    );
    if (userApprovedFee != null) {
      final userApproved = ETHHelper.toWei(userApprovedFee.fee.toString());
      final feeInWei = switch (tx.transactionType) {
        ETHTransactionType.eip1559 => tx.maxFeePerGas! * tx.gasLimit,
        _ => tx.gasPrice! * tx.gasLimit,
      };
      _logger.logInfoMessage(
        _name,
        'createTransactionOrThrow: feeInWei: $feeInWei '
        '(maxFeePerGas: ${tx.maxFeePerGas}, '
        'gasPrice: ${tx.gasPrice}, gasLimit: ${tx.gasLimit}), '
        'user approved: $userApproved',
      );
      if (userApproved < feeInWei) {
        throw AppFeeChangedException(
          userApprovedFee,
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
    required AppAsset asset,
    required ETHAddress toAddress,
    required int nonce,
    required FeeType feeType,
    required BigRational amount,
    String? memo,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
  }) async {
    ETHTransaction? tx;
    if (asset.token.blockchain.supportsEIP1559 && eip1559Fee != null) {
      _logger.logInfoMessage(
        _name,
        'Creating eip1559Fee transaction to ${toAddress.address}, '
        'amount: $amount',
      );
      final selectedFee = switch (feeType) {
        FeeType.economy => eip1559Fee.slow,
        FeeType.optimal => eip1559Fee.normal,
        FeeType.fast => eip1559Fee.high,
      };
      // Arbitrum uses a sequencer, so we add a safety buffer
      final maxFeePerGas = applyBufferMultiplier(
        selectedFee + eip1559Fee.baseFee,
      );
      tx = ETHTransaction(
        type: ETHTransactionType.eip1559,
        from: ETHAddress(asset.address),
        to: toAddress,
        nonce: nonce,
        gasLimit: BigInt.zero,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: selectedFee,
        data: [
          if (memo != null && memo.isNotEmpty) ...StringUtils.toBytes(memo),
        ],
        value: ETHHelper.toWei(amount.toString()),
        chainId: BigInt.from(asset.token.blockchain.chainId),
      );
    } else {
      if (asset.token.blockchain.supportsEIP1559) {
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
      tx = ETHTransaction(
        type: ETHTransactionType.legacy,
        from: ETHAddress(asset.address),
        to: toAddress,
        nonce: nonce,
        gasLimit: BigInt.zero,
        // Only for legacy and eip2930 transactions
        gasPrice: gasPrice,
        data: [
          if (memo != null && memo.isNotEmpty) ...StringUtils.toBytes(memo),
        ],
        value: ETHHelper.toWei(amount.toString()),
        chainId: BigInt.from(asset.token.blockchain.chainId),
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
    required AppAsset asset,
    required ETHAddress toAddress,
    required int nonce,
    required FeeType feeType,
    required BigRational amount,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
  }) async {
    ETHTransaction? tx;

    if (asset.token.blockchain.supportsEIP1559 && eip1559Fee != null) {
      _logger.logInfoMessage(
        _name,
        'Creating eip1559Fee ERC20 transaction to ${toAddress.address}, '
        'amount: $amount, token: ${asset.token.name}',
      );
      final selectedFee = switch (feeType) {
        FeeType.economy => eip1559Fee.slow,
        FeeType.optimal => eip1559Fee.normal,
        FeeType.fast => eip1559Fee.high,
      };

      final maxFeePerGas = applyBufferMultiplier(
        selectedFee + eip1559Fee.baseFee,
      );
      tx = ETHTransaction(
        type: ETHTransactionType.eip1559,
        from: ETHAddress(asset.address),
        to: ETHAddress(asset.token.contractAddress),
        nonce: nonce,
        gasLimit: BigInt.zero,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: selectedFee,
        data: ethTransferAbiFragment.encode([
          toAddress,
          DecimalConverter.toBigInt(
            amount: amount.toString(),
            decimals: asset.token.decimal,
          ),
        ]),
        value: BigInt.zero,
        chainId: BigInt.from(asset.token.blockchain.chainId),
      );
    } else {
      if (asset.token.blockchain.supportsEIP1559) {
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
      tx = ETHTransaction(
        type: ETHTransactionType.legacy,
        from: ETHAddress(asset.address),
        to: ETHAddress(asset.token.contractAddress),
        nonce: nonce,
        gasLimit: BigInt.zero,
        gasPrice: gasPrice,
        data: ethTransferAbiFragment.encode([
          toAddress,
          DecimalConverter.toBigInt(
            amount: amount.toString(),
            decimals: asset.token.decimal,
          ),
        ]),
        value: BigInt.zero,
        chainId: BigInt.from(asset.token.blockchain.chainId),
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
    required AppAsset asset,
    required String addressToCheck,
  }) async => false;

  /// Estimate gas fee for the dummy transaction
  ///
  /// [CoreConsts.defaultEthFeeType] = default for ETH
  Future<String> tryEstimateFee({
    required String addressToSend,
    required AppAsset asset,
    FeeType? feeType,
    // ERC20 token transfer fee depends on amount
    String amount = '0',
    String? message,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
  }) async {
    final parsedAmount = BigRational.tryParseDecimaal(amount);
    if (parsedAmount == null || parsedAmount <= BigRational.zero) {
      throw AppException(
        message: 'unable to create transaction: amount is not valid: $amount',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    final tx = await _tryCreateTransaction(
      toAddress: addressToSend,
      amount: parsedAmount,
      asset: asset,
      message: message,
      feeType: feeType,
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
    required String toAddress,
    required BigRational amount,
    required AppAsset asset,
    String? message,
    FeeType? feeType,
    EstimateFeeModel? userApprovedFee,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
    bool forceUpdateNonce = true,
  }) async {
    if (asset.token.blockchain.appBlockchain != appBlockchain) {
      throw AppIncorrectBlockchainException(
        appBlockchain.toString(),
        asset.token.blockchain.appBlockchain.toString(),
      );
    }

    if (amount < BigRational.zero) {
      throw AppException(
        message:
            'unable to create transaction: amount is not positive: $amount',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    final nonce = await _ethereumProvider.request(
      EthereumRequestGetTransactionCount(address: asset.address),
    );

    final to = ETHAddress(toAddress);

    if (asset.token.blockchain.supportsEIP1559) {
      eip1559Fee ??= await tryGetEip1559Fee();
    } else {
      gasPrice ??= await tryGetGasPrice();
    }

    return asset.token.tokenWalletType.isMaster
        ? await buildTransaction(
            rpc: _ethereumProvider,
            asset: asset,
            toAddress: to,
            nonce: nonce,
            feeType: feeType ?? CoreConsts.defaultEthFeeType,
            amount: amount,
            memo: message,
            gasPrice: gasPrice,
            eip1559Fee: eip1559Fee,
          )
        // Memo is not supported for standard ERC20 contracts
        : await buildERC20Transaction(
            rpc: _ethereumProvider,
            asset: asset,
            toAddress: to,
            nonce: nonce,
            feeType: feeType ?? CoreConsts.defaultEthFeeType,
            amount: amount,
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
