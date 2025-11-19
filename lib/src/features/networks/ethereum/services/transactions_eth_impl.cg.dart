import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:meta/meta.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain/ethereum/src/keys/private_key.dart';
import 'package:on_chain/ethereum/src/models/block_tag.dart';
import 'package:on_chain/ethereum/src/models/fee_history.dart';
import 'package:on_chain/ethereum/src/rpc/methds/estimate_gas.dart';
import 'package:on_chain/ethereum/src/rpc/methds/fee_history.dart';
import 'package:on_chain/ethereum/src/rpc/methds/get_gas_price.dart';
import 'package:on_chain/ethereum/src/rpc/methds/get_transaction_count.dart';
import 'package:on_chain/ethereum/src/rpc/provider/provider.dart';
import 'package:on_chain/ethereum/src/transaction/eth_transaction.dart';
import 'package:on_chain/ethereum/src/utils/helper.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service
///
/// Provides services for creating and signing ETHEREUM transactions
class TransactionsServiceEthereumImpl implements TransactionsService {
  /// Transactions Service
  ///
  /// Provides services for creating and signing ETHEREUM transactions
  TransactionsServiceEthereumImpl({
    required this.appBlockchain,
    required LocalRepoBaseCore localRepo,
    required Future<ErrOrTransactionInfo> Function({
      required String tx,
      required AppBlockchain appBlockchain,
      String? txFee,
    })
    postTransaction,
    this.rpc,
    this.apiUri,
    TRLogger? logger,
  }) : _localRepo = localRepo,
       _postTransaction = postTransaction,
       assert(
         rpc != null || apiUri != null,
         'Required rpc params are null',
       ),
       assert(
         supportedBlockchains.contains(appBlockchain),
         '$appBlockchain is not supported',
       ) {
    _logger = logger ?? InAppLogger();
  }

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain;

  final LocalRepoBaseCore _localRepo;

  /// Transaction sending
  final Future<ErrOrTransactionInfo> Function({
    required String tx,
    required AppBlockchain appBlockchain,
    String? txFee,
  })
  _postTransaction;

  /// Node provider
  final EthereumProvider? rpc;

  /// Ethereum API address
  final String? apiUri;

  String get _name => 'TransactionsServiceEthereumImpl-${appBlockchain.slug}';

  late final TRLogger _logger;

  EthereumProvider get _ethereumProvider =>
      rpc ??
      EthereumProvider(
        EthereumHTTPProvider(
          apiUri!,
          _localRepo.getAccount().token,
        ),
      );

  /// Current wallet nonce (outgoing transaction index)
  int? _nonce;

  /// Supported blockchains by this service
  static const List<AppBlockchain> supportedBlockchains = [
    AppBlockchain.ethereum,
    AppBlockchain.bsc,
  ];

  /// 6 Store (Broadcast)
  @override
  Future<TransactionInfoData> postTransactionOrThrow({
    required String tx,
    String? txFee,
  }) async {
    try {
      if (tx.isEmpty) {
        throw AppException(
          message: 'tx: $tx, txFee: $txFee',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }
      final res = await _postTransaction(
        tx: tx,
        appBlockchain: appBlockchain,
        txFee: txFee,
      );
      return res.fold((l) => throw l, (r) => r);
    } on Exception catch (e) {
      _logger.logCriticalError(_name, 'postTransactionOrThrow: $e');
      rethrow;
    } finally {
      _nonce = null;
    }
  }

  /// Create signed transaction for Ethereum or compatible token
  @override
  Future<String> createTransactionOrThrow({
    required String toAddress,
    required double amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    FeeType? feeType,
    EstimateFeeModel? userApprovedFee,
    String? txIdToPumpFeeBTC,
  }) async {
    try {
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
    } catch (_) {
      _nonce = null;
      rethrow;
    }
  }

  /// Create the transaction for the main coin of the blockchain (ex-Ethereum)
  @visibleForTesting
  Future<ETHTransaction> buildTransaction({
    required EthereumProvider rpc,
    required AppAsset asset,
    required ETHAddress toAddress,
    required int nonce,
    required FeeType feeType,
    required double amount,
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
      final maxFeePerGas = selectedFee + eip1559Fee.baseFee;
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
    final gasLimit = await rpc.request(
      EthereumRequestEstimateGas(transaction: tx.toEstimate()),
    );
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
    required double amount,
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
      final maxFeePerGas = selectedFee + eip1559Fee.baseFee;
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
    final gasLimit = await rpc.request(
      EthereumRequestEstimateGas(transaction: tx.toEstimate()),
    );
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
    double amount = 0,
    String? message,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
  }) async {
    final tx = await _tryCreateTransaction(
      toAddress: addressToSend,
      amount: amount,
      asset: asset,
      message: message,
      feeType: feeType,
      gasPrice: gasPrice,
      eip1559Fee: eip1559Fee,
      forceUpdateNonce: false,
    );
    final feeInWei = switch (tx.transactionType) {
      ETHTransactionType.eip1559 => tx.maxFeePerGas! * tx.gasLimit,
      _ => tx.gasPrice! * tx.gasLimit,
    };
    _logger.logInfoMessage(
      _name,
      'tryEstimateFee: $feeInWei (maxFeePerGas: ${tx.maxFeePerGas}, '
      'gasPrice: ${tx.gasPrice}, gasLimit: ${tx.gasLimit})',
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
  Future<({String address, List<int> pkAsBytes})>
  tryInitializeWalletAndGetInfoOrThrow({required String masterKey}) async {
    final pk = await _createSigningKeyOrThrow(masterKey: masterKey);
    return (
      address: pk.publicKey().toAddress().address,
      pkAsBytes: pk.toBytes(),
    );
  }

  /// Create a signing key for Ethereum
  Future<ETHPrivateKey> _createSigningKeyOrThrow({
    required String masterKey,
  }) async {
    final mnemonicFromRepo = await _localRepo
        // Take the current active Tron wallet
        .getMnemonic(
          publicKey: _localRepo.getAccount().publicKey,
          masterKey: masterKey,
        );
    if (mnemonicFromRepo.isEmpty) {
      throw AppException(code: ExceptionCode.unableToRetrieveMnemonic);
    }
    return KeyGenerator(mnemonic: mnemonicFromRepo).generateForEthereum();
  }

  /// Create transaction for Ethereum or compatible token
  ///
  /// [forceUpdateNonce] - do not use cached nonce
  Future<ETHTransaction> _tryCreateTransaction({
    required String toAddress,
    required double amount,
    required AppAsset asset,
    String? message,
    FeeType? feeType,
    EstimateFeeModel? userApprovedFee,
    BigInt? gasPrice,
    FeeHistorical? eip1559Fee,
    bool forceUpdateNonce = true,
  }) async {
    try {
      if (asset.token.blockchain.appBlockchain != appBlockchain) {
        throw AppIncorrectBlockchainException(
          appBlockchain.toString(),
          asset.token.blockchain.appBlockchain.toString(),
        );
      }

      if (amount < 0) {
        throw AppException(
          message:
              'unable to create transaction: amount is not positive: $amount',
          code: ExceptionCode.amountIsNotPositive,
        );
      }
      _nonce = (forceUpdateNonce || _nonce == null)
          ? await _ethereumProvider.request(
              EthereumRequestGetTransactionCount(address: asset.address),
            )
          : _nonce;
      if (_nonce == null) {
        throw AppException(
          message: 'Unable to retrieve wallet nonce',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }

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
              nonce: _nonce!,
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
              nonce: _nonce!,
              feeType: feeType ?? CoreConsts.defaultEthFeeType,
              amount: amount,
              gasPrice: gasPrice,
              eip1559Fee: eip1559Fee,
            );
    } catch (_) {
      _nonce = null;
      rethrow;
    }
  }

  Future<String> _trySignTransaction({
    required ETHTransaction tx,
    required String masterKey,
  }) async {
    final pk = await _createSigningKeyOrThrow(masterKey: masterKey);

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
