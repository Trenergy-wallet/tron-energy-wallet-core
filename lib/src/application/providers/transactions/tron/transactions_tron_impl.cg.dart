import 'dart:async';
import 'dart:convert';

import 'package:on_chain/solidity/contract/contract_abi.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/application/providers/transactions/tron/trc20_abi.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service
///
/// Provides services for creating and signing TRON transactions
class TransactionsServiceTronImpl implements TransactionsService {
  /// Transactions Service
  ///
  /// Provides services for creating and signing TRON transactions
  TransactionsServiceTronImpl({
    required LocalRepoBaseCore localRepo,
    required Future<ErrOrTransactionInfo> Function({
      required String tx,
      required AppBlockchain appBlockchain,
      String? txFee,
    })
    postTransaction,
    this.tronProvider,
    this.apiTron,
    TRLogger? logger,
  }) : _localRepo = localRepo,
       _postTransaction = postTransaction,
       assert(
         tronProvider != null || apiTron != null,
         'Required rpc params are null',
       ) {
    _logger = logger ?? InAppLogger();
  }

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain = AppBlockchain.tron;

  final LocalRepoBaseCore _localRepo;

  /// Transaction sending
  final Future<ErrOrTransactionInfo> Function({
    required String tx,
    required AppBlockchain appBlockchain,
    String? txFee,
  })
  _postTransaction;

  /// Node provider
  final TronProvider? tronProvider;

  /// TRON API address
  final String? apiTron;

  static const String _name = 'TransactionsServiceTronImpl';

  late final TRLogger _logger;

  TronProvider get _tronProvider =>
      tronProvider ??
      TronProvider(
        TronHTTPProvider(
          url: apiTron!,
          authToken: _localRepo.getAccount().token,
        ),
      );

  /// 6 Store (Broadcast)
  @override
  Future<TransactionInfoData> postTransactionOrThrow({
    required String tx,
    String? txFee,
  }) async {
    try {
      if (tx.isEmpty || (txFee != null && txFee.isEmpty)) {
        throw AppException(
          message: 'tx: $tx, txFee: $txFee',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }
      // final txdec = json.decode(tx) as Map<String, dynamic>;
      // final transaction = Transaction.fromJson(txdec);
      //
      // print(
      //   '💡TransactionsServiceTronImpl.postTransactionOrThrow :: transaction: ${transaction.toJson(visible: true, rawDataHex: true, txID: true)}',
      // );
      // print(
      //   '💡TransactionsServiceTronImpl.postTransactionOrThrow :: transaction HEX: ${transaction.toHex}',
      // );
      //
      // final res = await _tronProvider.request(
      //   TronRequestBroadcastHex(transaction: transaction.toHex),
      // );
      //
      // print('!! SENT res: ${res.result}');
      // return TransactionInfoData(
      //   txId: res.txid,
      //   linkToBlockchain: 'linkToBlockchain',
      // );
      final res = await _postTransaction(
        tx: tx,
        appBlockchain: appBlockchain,
        txFee: txFee,
      );
      return res.fold((l) => throw l, (r) => r);
    } on Exception catch (e) {
      _logger.logCriticalError(_name, 'postTransactionOrThrow: $e');
      rethrow;
    }
  }

  /// Send TRX
  ///
  /// [message] = memo field. If you include a memo, keep at least 1 TRX in
  /// your account to safely cover the additional cost
  @override
  Future<String> createTransactionOrThrow({
    required String toAddress,
    required double amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    FeeTypeBTC? feeTypeBTC,
    EstimateFeeModel? userApprovedFee,
    String? txIdToPumpFeeBTC,
  }) async {
    try {
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

      // Sending a transaction in TRX
      if (asset.isTrx) {
        _logger.logInfoMessage(_name, 'creating TRX transaction');

        // create transfer contract (TRX Transfer)
        final transferContract = TransferContract(
          amount: TronHelper.toSun(amount.toString()),
          ownerAddress: TronAddress(asset.address),
          toAddress: TronAddress(toAddress),
        );

        _logger.logInfoMessage(_name, 'transferContract: $transferContract');

        // validate transacation and got required data like block hash and ....
        final transaction = await _tronProvider.request(
          TronRequestCreateTransaction.fromContract(transferContract),
        );

        // Another way of creating transaction with memo included
        // final transaction = await _tronProvider.request(
        //   TronRequestCreateTransaction(
        //     ownerAddress: TronAddress(asset.address),
        //     toAddress: TronAddress(toAddress),
        //     amount: TronHelper.toSun(amount.toString()),
        //     extraData: message,
        //   ),
        // );

        print('!!! transaction: ${transaction.toJson()}');

        // Transaction lifetime
        // Default in the package is 1 minute, we set it ourselves to 10 minutes
        final transactionTTL = BigInt.from(
          DateTime.fromMillisecondsSinceEpoch(
            transaction.rawData.timestamp.toInt(),
            // 10 minutes TTL according to tasks 790 and 800
          ).add(const Duration(minutes: 10)).millisecondsSinceEpoch,
        );
        final rawTr = transaction.rawData.copyWith(
          expiration: transactionTTL,
          data: message == null ? null : utf8.encode(message),
        );

        // - feeLimit is not set here. See chat trenergy on 02.06.25
        return _signTransactionOrThrow(rawTr: rawTr, masterKey: masterKey);
      }
      _logger.logInfoMessage(_name, 'creating non-TRX transaction');
      // Send a non-TRX transaction
      // this many zeros need to be appended to one
      final buffer = StringBuffer()..write('1');
      for (var i = 0; i < asset.token.decimal; i++) {
        buffer.write('0');
      }

      final decimal = int.parse(buffer.toString());
      final totalAmount = amount * decimal;
      final contract = ContractABI.fromJson(trc20Abi);
      final function = contract.functionFromName('transfer');

      // address, amount
      final transferParams = [TronAddress(toAddress), BigInt.from(totalAmount)];

      final _contractAddress = TronAddress(asset.token.contractAddress);

      final transaction = await _tronProvider.request(
        TronRequestTriggerConstantContract(
          ownerAddress: TronAddress(asset.address),
          contractAddress: _contractAddress,
          data: function.encodeHex(transferParams),
        ),
      );

      _logger.logInfoMessage(_name, 'transaction: $transaction');

      // An error has occurred with the request, and we need to investigate
      // the issue to determine what is happening.
      if (!transaction.isSuccess) {
        throw AppRpcException(message: transaction.error.toString());
      }

      if (transaction.transaction == null) {
        throw AppRpcException(message: 'tron network returned no transaction');
      }

      // Transaction lifetime is set for all tokens except TRX.
      // Default in the package is 1 minute, we set it ourselves to 10 minutes
      final transactionTTL = BigInt.from(
        DateTime.fromMillisecondsSinceEpoch(
          transaction.transaction!.rawData.timestamp.toInt(),
          // 10 min TTL according to tickets 790 and 800
        ).add(const Duration(minutes: 10)).millisecondsSinceEpoch,
      );

      // Get transactionRaw from response and make sure set fee limit
      // If you include a memo, keep at least 1 TRX in your account to safely
      // cover the additional cost
      final rawTr = transaction.transaction!.rawData.copyWith(
        feeLimit: TronHelper.toSun('100'),
        expiration: transactionTTL,
        data: message == null ? null : utf8.encode(message),
      );

      return _signTransactionOrThrow(rawTr: rawTr, masterKey: masterKey);
    } on Exception catch (e) {
      if (e is! IncorrectPinCodeException) {
        _logger.logCriticalError(_name, 'createTransaction: $e');
      }
      rethrow;
    }
  }

  Future<String> _signTransactionOrThrow({
    required TransactionRaw rawTr,
    required String masterKey,
  }) async {
    final account = _localRepo.getAccount();
    final pk = await _localRepo.getPK(
      publicKey: account.publicKey,
      masterKey: masterKey,
    );

    if (pk == null) {
      throw AppException(
        message: 'No private wallet key saved for ${account.address}',
        code: ExceptionCode.noPrivateKeySaved,
      );
    }

    // Get transaaction digest and sign with private key
    final sign = pk.sign(rawTr.toBuffer());

    // Create transaction object and add raw data and signature to this
    final transaction = Transaction(rawData: rawTr, signature: [sign]);

    return json.encode(
      transaction.toJson(rawDataHex: true, txID: true, visible: true),
    );
  }

  @override
  Future<({String address, List<int> pkAsBytes})>
  tryInitializeWalletAndGetInfoOrThrow({required String masterKey}) async {
    // For simplicity, we assume that we are always initialized on the TRON
    // network
    return (address: _localRepo.getAccount().address, pkAsBytes: <int>[]);
  }

  @override
  Future<bool> checkWalletIsFrozen({
    required AppAsset asset,
    required String addressToCheck,
  }) async => false;
}
