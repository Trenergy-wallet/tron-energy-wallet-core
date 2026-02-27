import 'dart:async';
import 'dart:convert';

import 'package:on_chain/solidity/contract/contract_abi.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service
///
/// Provides services for creating and signing TRON transactions
class TransactionsServiceTronImpl
    implements TransactionsService<TransferParamsTRON> {
  /// Transactions Service
  ///
  /// Provides services for creating and signing TRON transactions
  TransactionsServiceTronImpl({
    required Future<TronPrivateKey?> Function(String masterKey) getSigningKey,
    this.tronProvider,
    this.apiTron,
    String Function()? getAuthToken,
    TRLogger? logger,
  }) : _getSigningKey = getSigningKey,
       _getAuthToken = getAuthToken,
       assert(
         tronProvider != null || apiTron != null,
         'Required rpc params are null',
       ) {
    _logger = logger ?? InAppLogger();
  }

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain = AppBlockchain.tron;

  /// Node provider
  final TronProvider? tronProvider;

  /// TRON API address
  final String? apiTron;

  /// Auth token for the backend
  final String Function()? _getAuthToken;

  /// Get Tron private key as String
  final Future<TronPrivateKey?> Function(String masterKey) _getSigningKey;

  static const String _name = 'TransactionsServiceTronImpl';

  late final TRLogger _logger;

  TronProvider get _tronProvider =>
      tronProvider ??
      TronProvider(
        TronHTTPProvider(
          url: apiTron!,
          // authToken: _localRepo.getAccount().token,
          authToken: _getAuthToken?.call(),
        ),
      );

  /// Send TRX
  ///
  /// params.message = memo field. If you include a memo, keep at least 1 TRX in
  /// your account to safely cover the additional cost
  @override
  Future<String> createTransaction({
    required TransferParamsTRON params,
    required String masterKey,
  }) async {
    if (!params.amount.isPositive) {
      throw AppException(
        message:
            'unable to create transaction: amount is not '
            'valid: ${params.amount}',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    // Sending a transaction in TRX
    if (params.tokenWalletType.isMaster) {
      _logger.logInfoMessage(_name, 'creating TRX transaction');

      // Create transfer contract (TRX Transfer)
      final transferContract = TransferContract(
        amount: TronHelper.toSun(params.amount.toString()),
        ownerAddress: TronAddress(params.from),
        toAddress: TronAddress(params.to),
      );

      _logger.logInfoMessage(_name, 'transferContract: $transferContract');

      // Validate transacation and got required data like block hash and ....
      final transaction = await _tronProvider.request(
        TronRequestCreateTransaction.fromContract(transferContract),
      );

      // Another way of creating transaction with memo included
      // final transaction = await _tronProvider.request(
      //   TronRequestCreateTransaction(
      //     ownerAddress: TronAddress(params.from),
      //     toAddress: TronAddress(params.to),
      //     amount: TronHelper.toSun(params.amount.toString()),
      //     extraData: params.message,
      //   ),
      // );

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
        data: params.message == null ? null : utf8.encode(params.message!),
      );

      // - feeLimit is not set here. See chat trenergy on 02.06.25
      return _signTransaction(rawTr: rawTr, masterKey: masterKey);
    }
    _logger.logInfoMessage(_name, 'creating non-TRX transaction');
    if (params.tokenContractAddress == null) {
      throw AppException(
        message: 'no tokenContractAddress for non-TRX transaction',
        code: ExceptionCode.unableToCreateTransaction,
      );
    }

    final contract = ContractABI.fromJson(trc20Abi);
    final function = contract.functionFromName('transfer');

    // address, amount
    final transferParams = [
      TronAddress(params.to),
      DecimalConverter.toBigInt(
        amount: params.amount.toString(),
        decimals: params.tokenDecimal,
      ),
    ];

    final _contractAddress = TronAddress(params.tokenContractAddress!);

    final transaction = await _tronProvider.request(
      TronRequestTriggerConstantContract(
        ownerAddress: TronAddress(params.from),
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
      data: params.message == null ? null : utf8.encode(params.message!),
    );

    return _signTransaction(rawTr: rawTr, masterKey: masterKey);
  }

  Future<String> _signTransaction({
    required TransactionRaw rawTr,
    required String masterKey,
  }) async {
    final pk = await _getSigningKey(masterKey);
    if (pk == null) {
      throw AppException(code: ExceptionCode.noPrivateKeySaved);
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
  Future<({String address, List<int> pkAsBytes})> initializeWalletAndGetInfo({
    required String masterKey,
  }) async {
    // For simplicity, we assume that we are always initialized on the TRON
    // network
    return (address: 'tron address', pkAsBytes: <int>[]);
  }

  @override
  Future<bool> checkWalletIsFrozen({
    required String assetAddress,
    required String addressToCheck,
  }) async => false;
}
