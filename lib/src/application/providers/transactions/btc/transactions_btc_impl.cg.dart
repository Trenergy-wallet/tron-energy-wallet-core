import 'dart:async';
import 'dart:math';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:meta/meta.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service
///
/// Provides services for creating and signing Bitcoin transactions
///
/// SigningKeyCreatorBTC contains shared variables for this service and
/// the transaction length calculation service

class TransactionsServiceBTCImpl
    with SingingKeyCreatorBTC
    implements TransactionsService {
  /// Transactions Service
  ///
  /// Provides services for creating and signing Bitcoin transactions
  TransactionsServiceBTCImpl({
    required this.network,
    required this.localRepo,
    required this.btcNodeRepo,
    required Future<ErrOrTransactionInfo> Function({
      required String tx,
      required AppBlockchain appBlockchain,
      String? txFee,
    })
    postTransaction,
    required Future<ErrOrEstimateFee> Function({
      required double amount,
      required AppBlockchain appBlockchain,
      required TokenWalletType tokenWalletType,
      String? recipientAddress,
      String? tokenContractAddress,
    })
    estimateFee,
  }) : _postTransaction = postTransaction,
       _estimateFee = estimateFee;

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain = AppBlockchain.bitcoin;

  /// Bitcoin network used by the service
  @override
  final BitcoinNetwork network;

  @override
  final String name = 'TransactionsServiceBTCImpl';

  /// Transaction sending
  final Future<ErrOrTransactionInfo> Function({
    required String tx,
    required AppBlockchain appBlockchain,
    String? txFee,
  })
  _postTransaction;

  @protected
  @override
  final BTCNodeRepo btcNodeRepo;

  @protected
  @override
  final LocalRepoBaseCore localRepo;

  /// 2.4. Estimate Tx Energy Fee
  ///
  /// For Bitcoin, the fees section shows the cost in sat/vB (satoshis per ONE
  /// virtual byte)
  final Future<ErrOrEstimateFee> Function({
    required double amount,
    required AppBlockchain appBlockchain,
    required TokenWalletType tokenWalletType,
    String? recipientAddress,
    String? tokenContractAddress,
  })
  _estimateFee;

  /// 6 Store (Broadcast)
  @override
  Future<TransactionInfoData> postTransactionOrThrow({
    required String tx,
    String? txFee,
  }) async {
    try {
      if (tx.isEmpty) {
        throw AppException(code: ExceptionCode.unableToCreateTransaction);
      }
      final res = await _postTransaction(tx: tx, appBlockchain: appBlockchain);

      return res.fold((l) => throw l, (r) => r);
    } on Exception catch (e) {
      logger.logCriticalError(name, 'postTransactionOrThrow: $e');
      rethrow;
    }
  }

  @override
  Future<String> createTransactionOrThrow({
    required String toAddress,
    required double amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    String? requestPinMessage,
    FeeTypeBTC? feeTypeBTC,
    EstimateFeeModel? userApprovedFee,
    String? txIdToPumpFeeBTC,
  }) async {
    String? signedTransaction;
    try {
      final (
        transactionVSize: transactionVSize,
        pendingTransactions: pendingTransactions,
        sumOfUtxo: sumOfUtxo,
        sumOfOutputs: sumOfOutputs,
        outPuts: outPuts,
        spender3Taproot: spender3Taproot,
        accountsUtxos: accountsUtxos,
        senderPrivateKey: senderPrivateKey,
        memo: memo,
        maxRbfTransactionFeeRatePer1B: maxRbfTransactionFeeRatePer1vB,
      ) = await prepareTransactionAndCalculateSizeOrThrow(
        toAddress: toAddress,
        amount: amount,
        asset: asset,
        masterKey: masterKey,
        message: message,
        txIdToPumpFeeBTC: txIdToPumpFeeBTC,
      );
      // 4.2 Get fee rates per byte from the backend
      final networkEstimate = (await _estimateFee(
        amount: amount,
        appBlockchain: appBlockchain,
        tokenWalletType: asset.token.tokenWalletType,
        tokenContractAddress: asset.token.contractAddress,
      )).fold((l) => throw l, (r) => r);
      if (networkEstimate.fees == Fees.invalid) {
        throw AppException(
          message: 'BTC fees are invalid: ${networkEstimate.fees}',
          code: ExceptionCode.amountIsNotPositive,
        );
      }

      // 4.3.1 Choose the appropriate fee rate based on the user's selection in
      // the UI
      // If we reached this point, feeTypeBTC is already not null since it was
      // checked earlier
      final feePer1vBCurrent = networkEstimate.fees.feeForType(feeTypeBTC!);

      // 4.3.1 If we got an approved model, check if the fees were changed
      if (userApprovedFee != null) {
        final feePer1vUserSelected = userApprovedFee.fees.feeForType(
          feeTypeBTC,
        );
        logger.logInfoMessage(
          name,
          'FeeType: $feeTypeBTC, user selected fee: $feePer1vUserSelected,'
          ' current in blockchain: $feePer1vBCurrent',
        );
        if (feePer1vBCurrent > feePer1vUserSelected) {
          throw AppFeeChangedException(userApprovedFee, networkEstimate);
        }
      }
      // 4.3.3 Choose which transaction fee cost to use: either the one
      // currently in the network [feePer1vBCurent] or the one that was already
      // in the rbf transaction
      final feePer1vB = max(feePer1vBCurrent, maxRbfTransactionFeeRatePer1vB);

      if (feePer1vB < networkEstimate.fees.minimumFee) {
        throw AppException(
          message: 'Fee is too low: $feePer1vB',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }

      // 4.4 Final fee amount
      final fee = BigInt.from(feePer1vB * transactionVSize);
      // 4.5 If we use RBF inputs, it's mandatory to check that the fee in the
      // new transaction  is higher than in the previous one
      // RBF = a transaction with a higher fee replaces one with a lower fee,
      // given they share inputs
      final feesInReplacedRbfTransactions = pendingTransactions.fold(
        0,
        (prev, next) => prev + next.fees!,
      );
      if (BigInt.from(feesInReplacedRbfTransactions).compareTo(fee) >= 0) {
        throw AppException(
          message:
              'New transaction fee $fee is less or equal sum of '
              'replaced RBF transactions: $feesInReplacedRbfTransactions',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }
      logger.logInfoMessage(
        name,
        'createTransactionOrThrow: fee per vB: $feePer1vB, total fee: '
        '$fee ${pendingTransactions.isNotEmpty ? ''
                  ', was $feesInReplacedRbfTransactions' : ''}',
      );
      // 5 Calculate change
      // changeValue - the amount returned back as change
      final changeValue = sumOfUtxo - (sumOfOutputs + fee);
      logger.logInfoMessage(
        name,
        'createTransactionOrThrow: changeValue: $changeValue',
      );
      if (changeValue.isNegative || fee.isNegative) {
        throw AppException(
          message: 'Not enough balance: changeValue: $changeValue, fee: $fee',
          code: ExceptionCode.amountIsNotPositive,
        );
      }
      // 5.1 If change is positive, add it to the outputs replacing the
      // placeholder
      if (changeValue > BigInt.zero) {
        outPuts.add(
          BitcoinOutput(address: spender3Taproot, value: changeValue),
        );
      }
      // 6 Assemble the transaction
      final builder = BitcoinTransactionBuilder(
        outPuts: outPuts,
        fee: fee,
        network: network,
        utxos: accountsUtxos,
        memo: memo,
        enableRBF: true,
      );
      final transaction = await builder.buildTransactionAsync((
        trDigest,
        utxo,
        publicKey,
        sigHash,
      ) async {
        if (utxo.utxo.isP2tr) {
          return senderPrivateKey.signBip340(trDigest, sighash: sigHash);
        }
        return senderPrivateKey.signECDSA(trDigest, sighash: sigHash);
      });

      final txId = transaction.txId();
      logger.logInfoMessage(name, 'createTransactionOrThrow: txId: $txId');
      signedTransaction = transaction.serialize();
      logger.logInfoMessage(
        name,
        'createTransactionOrThrow: signedTransaction: $signedTransaction',
      );
      if (signedTransaction.isEmpty) {
        throw AppException(code: ExceptionCode.unableToCreateTransaction);
      }
      return signedTransaction;
    } catch (e) {
      if (e is! IncorrectPinCodeException) {
        logger.logCriticalError(name, 'createTransactionOrThrow: $e');
      }
      rethrow;
    }
  }

  @override
  Future<({String address, List<int> pkAsBytes})>
  tryInitializeWalletAndGetInfoOrThrow({String? masterKey}) async {
    if (masterKey == null) {
      throw AppException(
        message: 'master key is null',
        code: ExceptionCode.unableToDecodeWallet,
      );
    }
    final pk = await createSigningKeyOrThrow(masterKey: masterKey);
    final publicKey = pk.getPublic();
    return (
      address: publicKey.toTaprootAddress().toAddress(network),
      pkAsBytes: pk.toBytes(),
    );
  }

  @override
  Future<bool?> checkWalletIsFrozen({
    required AppAsset asset,
    required String addressToCheck,
  }) async => false;
}

/// Class for storing the method of creating a Bitcoin signing key
mixin SingingKeyCreatorBTC {
  /// Blockchain
  AppBlockchain get appBlockchain;

  /// Имя
  @protected
  String get name;

  /// Logger
  @protected
  final InAppLogger logger = InAppLogger.instance;

  /// Local repo
  @protected
  LocalRepoBaseCore get localRepo;

  /// BtcNodeRepo
  @protected
  BTCNodeRepo get btcNodeRepo;

  /// Which network we are working on
  BitcoinNetwork get network;

  /// Create a signing key for BTC
  Future<ECPrivate> createSigningKeyOrThrow({required String masterKey}) async {
    final mnemonicFromRepo = await localRepo
        // Take the current active Tron wallet
        .getMnemonic(
          publicKey: localRepo.getAccount().publicKey,
          masterKey: masterKey,
        );
    if (mnemonicFromRepo.isEmpty) {
      throw AppException(code: ExceptionCode.unableToRetrieveMnemonic);
    }
    return KeyGenerator(mnemonic: mnemonicFromRepo).generateForBitcoin();
  }

  /// All calculations we are forced to perform to determine
  /// the transaction size
  Future<
    ({
      int transactionVSize,
      List<TransactionBtcNode> pendingTransactions,
      BigInt sumOfUtxo,
      BigInt sumOfOutputs,
      List<BitcoinOutput> outPuts,
      P2trAddress spender3Taproot,
      List<UtxoWithAddress> accountsUtxos,
      ECPrivate senderPrivateKey,
      int maxRbfTransactionFeeRatePer1B,
      String? memo,
    })
  >
  prepareTransactionAndCalculateSizeOrThrow({
    required String toAddress,
    required double amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    String? txIdToPumpFeeBTC,
  }) async {
    if (asset.token.blockchain.appBlockchain != appBlockchain) {
      throw AppIncorrectBlockchainException(
        appBlockchain.toString(),
        asset.token.blockchain.appBlockchain.toString(),
      );
    }
    if (amount <= 0) {
      throw AppException(
        message:
            'unable to create transaction: amount is not positive: $amount',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    if (txIdToPumpFeeBTC != null && txIdToPumpFeeBTC.isEmpty) {
      throw AppException(
        message: 'Invalid txId for transaction to bump fee',
        code: ExceptionCode.unableToCreateTransaction,
      );
    }
    final senderPrivateKey = await createSigningKeyOrThrow(
      masterKey: masterKey,
    );
    switch (asset.token.tokenWalletType) {
      // No wallet types other than master (btc) are supported
      case TokenWalletType.child:
      case TokenWalletType.stable:
      case TokenWalletType.unknown:
        throw AppException(
          message: '${asset.token.tokenWalletType} is not supported',
          code: ExceptionCode.tokenIsNotSupported,
        );
      // Работаем с самим биткоином
      case TokenWalletType.master:
        logger.logInfoMessage(name, 'Creating btc transaction');
        final addressToSend = BitcoinAddress(
          toAddress,
          network: network,
        ).baseAddress;
        // Message that will be recorded in the transaction
        // for txIdToPumpFeeBTC we get it from the node
        var messageToInclude = txIdToPumpFeeBTC == null ? message : null;

        final publicKey = senderPrivateKey.getPublic();
        // 1. Selecting the spender
        // Take ONLY the Taproot spender
        final spender3Taproot = publicKey.toTaprootAddress();
        final spender3TaprootAddres = spender3Taproot.toAddress(network);
        // Check that we are working with the correct wallet
        if (asset.address != spender3TaprootAddres) {
          throw AppException(
            message:
                'Address from asset: ${asset.address}, address from '
                'account: ${spender3Taproot.toAddress(network)}',
            code: ExceptionCode.unableToDecodeWallet,
          );
        }
        // We can take the balance from any of them or from multiple
        final spenders = <BitcoinBaseAddress>[spender3Taproot];
        logger.logInfoMessage(
          name,
          'Send from address: $spender3TaprootAddres',
        );
        // 2. Getting unspent outputs (UTXO)
        // Inputs that will be spent (Unspent Transaction Outputs)
        final accountsUtxos = <UtxoWithAddress>[];
        // Outputs that are already linked in unconfirmed transactions
        final pendingUtxos = <AppUtxo>[];

        // loop each spenders address and get utxos and add to accountsUtxos
        for (final i in spenders) {
          final utxosResponse = await btcNodeRepo.fetchUtxosV2(
            address: i.toAddress(network),
            confirmed: true,
          );
          // 2.1 Retrieve inputs from the node
          final utxos = utxosResponse.fold((l) => throw l, (r) => r);
          // 2.2 Convert them into a model for the builder
          final utxosWithAddress = utxos
              .map(
                (e) => UtxoWithAddress(
                  utxo: BitcoinUtxo(
                    txHash: e.txid,
                    value: e.value,
                    vout: e.vout,
                    scriptType: i.type,
                    blockHeight: e.height,
                  ),
                  ownerDetails: UtxoAddressDetails(
                    publicKey: publicKey.toHex(),
                    address: i,
                  ),
                ),
              )
              .toList();
          accountsUtxos.addAll(utxosWithAddress);
          // 2.3 Prepare outputs for RBF
          // The node has a cache, so we forcibly request confirmed inputs via
          // v2 API and unconfirmed via v1
          final pendingTransactionsResponse = await btcNodeRepo.fetchUtxosV1(
            address: i.toAddress(network),
            confirmed: false,
          );
          final utxosPending = pendingTransactionsResponse.fold(
            (l) => throw l,
            (r) => r,
          );
          pendingUtxos.addAll(utxosPending.where((e) => e.confirmations == 0));
        }
        if (pendingUtxos.isNotEmpty) {
          logger.logInfoMessage(
            name,
            'pending transactions: '
            '${pendingUtxos.map((e) => e.txid).join(',')}',
          );
        }
        // Total sum of all inputs
        final sumOfUtxo = accountsUtxos.sumOfUtxosValue();
        logger.logInfoMessage(name, 'sumOfUtxo: $sumOfUtxo');
        // Nothing to spend
        if (sumOfUtxo == BigInt.zero) {
          throw AppException(
            message: 'sumOfUtxo is zero',
            code: ExceptionCode.amountIsNotPositive,
          );
        }

        logger.logInfoMessage(
          name,
          'will send to $spender3TaprootAddres on ${network.identifier}',
        );

        // 3. Assembling outputs (BitcoinOutput)
        // 3.1 Add the main transaction output
        final outPuts = <BitcoinOutput>[
          // If we are only bumping the fee for txIdToPumpFeeBTC this
          // output is not added - data for this transaction will be taken
          // from the endpoint
          if (txIdToPumpFeeBTC == null)
            BitcoinOutput(
              address: addressToSend,
              value: BtcUtils.toSatoshi(amount.toString()),
            ),
        ];
        // 3.2 Add our RBF unconfirmed transactions to the outputs
        final pendingTransactions = <TransactionBtcNode>[];
        // 3.2.1 Get information about each such transaction
        for (final utxo in pendingUtxos) {
          final txResponse = await btcNodeRepo.fetchTransaction(
            txId: utxo.txid,
          );
          txResponse.fold((l) => throw l, (r) {
            // Sometimes the node glitches and shows confirmed transactions as
            // unconfirmed, we additionally check that the transaction indeed
            // has no confirmations yet
            if (r.isPending) pendingTransactions.add(r);
          });
        }
        // 3.3 Clean the transaction list of those that use inputs
        // which we do not engage
        pendingTransactions.retainWhere(
          (pt) => pt.vin.any(
            (v) =>
                accountsUtxos.any((accUtxo) => accUtxo.utxo.txHash == v.txId),
          ),
        );

        // If the requested transaction for fee bump is not in the
        // unconfirmed list, exit
        if (txIdToPumpFeeBTC != null &&
            !pendingTransactions.any((e) => e.txId == txIdToPumpFeeBTC)) {
          throw AppException(
            message:
                'Tx with id $txIdToPumpFeeBTC is not in pending transactions',
            code: ExceptionCode.unableToCreateTransaction,
          );
        }

        var maxRbfTransactionFeeRate = 0;

        // 3.4 Process all remaining unconfirmed transactions
        for (final pendingTransaction in pendingTransactions) {
          // If a non-RBF transaction has locked our outputs, then there’s
          // nothing we can do
          if (!pendingTransaction.rbf) {
            throw AppException(
              message:
                  'Non rbf transaction is pending: '
                  '${pendingTransaction.txId}',
              code: ExceptionCode.unableToCreateTransaction,
            );
          }
          // 3.5 From pending transactions, select the outputs we need
          // message is not taken here (it will be used only when bumping fee
          // of existing transaction)
          final outputsRbfToAdd = pendingTransaction
              .onlyTransfersToOutputsOrThrow(
                network: network,
                includeMessage: txIdToPumpFeeBTC != null,
                senderAddress: spender3TaprootAddres,
              );
          // Here we need to calculate the fee rate with which the previous
          // transaction was sent
          if (outputsRbfToAdd.outputs.isNotEmpty &&
              pendingTransaction.fees != null) {
            // For all comparisons, use vSize
            // https://learnmeabitcoin.com/technical/transaction/size/
            maxRbfTransactionFeeRate = max(
              (pendingTransaction.fees! / pendingTransaction.vSize).ceil(),
              maxRbfTransactionFeeRate,
            );
            // If we have an RBF transaction whose inputs we use,
            // add 1 sat/vB more so it definitely replaces the previous one
            if (maxRbfTransactionFeeRate > 0) maxRbfTransactionFeeRate++;

            logger.logInfoMessage(
              '_SingingKeyCreatorBTC',
              'RBF maxRbfTransactionFeeRate = '
                  '$maxRbfTransactionFeeRate, tx: ${pendingTransaction.txId},'
                  ' fees: ${pendingTransaction.fees}, vSize: '
                  '${pendingTransaction.vSize}',
            );
          }

          // Save in the log exactly what we want to add to outputs
          for (final output in outputsRbfToAdd.outputs) {
            logger.logInfoMessage(
              name,
              'Will add output from '
              '${pendingTransaction.txId}: value ${output.value} to '
              '${output.address.toAddress(network)}',
            );
          }
          outPuts.addAll(outputsRbfToAdd.outputs);
          // Take the comment if we are only bumping the fee
          if (pendingTransaction.txId == txIdToPumpFeeBTC) {
            messageToInclude = outputsRbfToAdd.message;
            if (messageToInclude != null) {
              logger.logInfoMessage(name, 'Use message: $messageToInclude');
            }
          }
        }
        // It is illogical to create a transaction from only change output,
        // something went wrong
        if (outPuts.isEmpty) {
          throw AppException(
            message: 'Outputs is empty',
            code: ExceptionCode.unableToCreateTransaction,
          );
        }
        // OP_RETURN
        final memo = convertMessageForOpReturn(messageToInclude);
        // SUM OF OUTOUT AMOUNTS
        final sumOfOutputs = outPuts.fold(
          BigInt.zero,
          (previousValue, element) => previousValue + element.value,
        );
        // 4 Fee calculation
        // 4.1 Calculate transaction size
        final transactionVSize =
            BitcoinTransactionBuilder.estimateTransactionSize(
              utxos: accountsUtxos,
              outputs: [
                ...outPuts,
                // Output for crediting change - currently a placeholder
                BitcoinOutput(address: spender3Taproot, value: BigInt.zero),
              ],
              network: network,
              // OP_RETURN
              memo: memo,
              // rbf - replace by fee
              enableRBF: true,
            );
        return (
          transactionVSize: transactionVSize,
          pendingTransactions: pendingTransactions,
          sumOfUtxo: sumOfUtxo,
          sumOfOutputs: sumOfOutputs,
          outPuts: outPuts,
          spender3Taproot: spender3Taproot,
          accountsUtxos: accountsUtxos,
          senderPrivateKey: senderPrivateKey,
          memo: memo,
          maxRbfTransactionFeeRatePer1B: maxRbfTransactionFeeRate,
        );
    }
  }
}
