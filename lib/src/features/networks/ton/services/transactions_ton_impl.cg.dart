import 'dart:async';

import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tr_ton_wallet_service/tr_ton_wallet_service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service
///
/// Provides services for creating and signing transactions
class TransactionsServiceTonImpl implements TransactionsService {
  /// Transactions Service
  ///
  /// Provides services for creating and signing transactions
  ///
  /// For working on the testnet, you must provide either [tonProvider]
  /// or [testApiKey]
  TransactionsServiceTonImpl({
    required LocalRepoBaseCore localRepo,
    required Future<ErrOrTransactionInfo> Function({
      required String tx,
      required AppBlockchain appBlockchain,
      String? transactionType,
      String? txFee,
    })
    postTransaction,
    required String? Function() currentAccountWallet,
    required this.isTestnet,
    this.tonProvider,
    this.apiTon,
    this.apiTonJrpc,
    this.testApiKey,
    TRLogger? logger,
  }) : _localRepo = localRepo,
       _postTransaction = postTransaction,
       _currentAccountWallet = currentAccountWallet,
       assert(
         tonProvider != null || (apiTon != null && apiTonJrpc != null),
         'Required rpc params are null',
       ) {
    _logger = logger ?? InAppLogger();
  }

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain = AppBlockchain.ton;

  /// Network for which the initialization was completed
  final bool isTestnet;

  final LocalRepoBaseCore _localRepo;

  /// Transaction sending
  final Future<ErrOrTransactionInfo> Function({
    required String tx,
    required AppBlockchain appBlockchain,
    String? transactionType,
    String? txFee,
  })
  _postTransaction;

  final String? Function() _currentAccountWallet;

  /// TON Wallet service
  TonWalletService? _walletService;

  /// Node provider
  final TonProvider? tonProvider;

  /// Access key for the TON testnet API
  final String? testApiKey;

  /// Access address for the TON API
  final String? apiTon;

  /// Access address for the TON API (JRPC)
  final String? apiTonJrpc;

  static const String _name = 'TransactionsServiceTonImpl';

  late final TRLogger _logger;

  /// Jetton wallets
  final Map<int, TonJettonWalletService> _jettonWallets = {};

  TonProvider get _rpc =>
      tonProvider ??
      TonProvider(
        TonHTTPProvider(
          tonApiUrl: apiTon, // 'https://testnet.tonapi.io',
          tonCenterUrl: apiTonJrpc, // 'https://testnet.toncenter.com',
          tonApiKey: testApiKey,
          authToken: _localRepo.getAccount().token,
        ),
        // TonHTTPProvider(
        //     tonApiUrl: 'https://tonapi.io',
        //     tonCenterUrl: 'https://toncenter.com',
        //     authToken: _mainNetApiKey),
      );

  /// 6 Store (Broadcast)
  @override
  Future<TransactionInfoData> postTransactionOrThrow({
    required String tx,
    String? transactionType,
    String? txFee,
  }) async {
    try {
      if (tx.isEmpty) {
        throw AppException(code: ExceptionCode.unableToCreateTransaction);
      }
      final res = await _postTransaction(
        tx: tx,
        appBlockchain: appBlockchain,
        transactionType: transactionType,
      );

      return res.fold((l) => throw l, (r) => r);
    } on Exception catch (e) {
      _logger.logCriticalError(_name, 'postTransactionOrThrow: $e');
      rethrow;
    }
  }

  @override
  Future<String> createTransactionOrThrow({
    required String toAddress,
    required BigRational amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    FeeType? feeType,
    EstimateFeeModel? userApprovedFee,
    String? txIdToPumpFeeBTC,
  }) async {
    String? signedTransaction;
    try {
      if (asset.token.blockchain.appBlockchain != appBlockchain) {
        throw AppIncorrectBlockchainException(
          appBlockchain.toString(),
          asset.token.blockchain.appBlockchain.toString(),
        );
      }
      if (!amount.isPositive) {
        throw AppException(
          message: 'unable to create transaction: amount is not valid: $amount',
          code: ExceptionCode.amountIsNotPositive,
        );
      }
      final walletInfo = await tryInitializeWalletAndGetInfoOrThrow(
        masterKey: masterKey,
      );
      // Failed to initialize the service, exiting
      if (_walletService == null) {
        throw AppException(
          message:
              'Initialisation error for walletService: asset: '
              '${asset.token.name}',
          code: ExceptionCode.unableToInitializeWalletService,
        );
      }
      // If the key is provided, use it directly
      final key = walletInfo.pkAsBytes.isEmpty
          ? await _createSigningKeyOrThrow(masterKey: masterKey)
          : TonPrivateKey.fromBytes(walletInfo.pkAsBytes);
      switch (asset.token.tokenWalletType) {
        case TokenWalletType.master:
          signedTransaction = await _walletService?.createTransfer(
            accessKey: key,
            addressTo: toAddress,
            amount: amount.toString(),
            message: message,
            sendToBlockchain: false,
          );
        case TokenWalletType.child:
          var jettonWalletService = _jettonWallets[asset.token.id];
          if (asset.childWalletAddress.isEmpty) {
            throw AppException(
              message:
                  'No jettonWalletAddress provided for master '
                  'wallet ${asset.address}',
              code: ExceptionCode.noJettonWallet,
            );
          }
          jettonWalletService ??= await _walletService?.openJettonWallet(
            jettonContractAddress: asset.token.contractAddress,
            jettonWalletAddress: asset.childWalletAddress,
            jettonOnChainMetadata: JettonOnChainMetadata.snakeFormat(
              name: asset.token.name,
              image: asset.token.icon,
              symbol: asset.token.shortName,
              decimals: asset.token.decimal,
            ),
          );
          if (jettonWalletService == null) {
            throw AppException(
              message:
                  'Unable to initialise jetton service for '
                  'token ${asset.token.name}',
              code: ExceptionCode.unableToInitializeWalletService,
            );
          }
          _jettonWallets[asset.token.id] = jettonWalletService;
          signedTransaction = await jettonWalletService.sendJettons(
            key: key,
            amount: amount.toString(),
            recipient: TonAddress(toAddress),
            sendToBlockchain: false,
            message: message,
          );
        case TokenWalletType.stable:
        case TokenWalletType.unknown:
          throw AppException(
            message: '${asset.token.tokenWalletType} is not supported',
            code: ExceptionCode.tokenIsNotSupported,
          );
      }
      if (signedTransaction == null || signedTransaction.isEmpty) {
        throw AppException(code: ExceptionCode.unableToCreateTransaction);
      }
      return signedTransaction;
    } catch (e) {
      if (e is! IncorrectPinCodeException) {
        _logger.logCriticalError(_name, 'createTransaction: $e');
      }
      rethrow;
    }
  }

  /// Wallet initialization check
  ///
  /// String address = success
  /// null = failure
  @override
  Future<({String address, List<int> pkAsBytes})>
  tryInitializeWalletAndGetInfoOrThrow({required String masterKey}) async {
    try {
      if (_walletService != null) {
        // Check if the account switch has been done to reset
        // the current state
        final initializedTonAddress = _walletService!.tonWallet.address
            .toString();
        // On the backend, if the address matches the already initialized one,
        // return it otherwise, perform initialization
        if (_currentAccountWallet() == initializedTonAddress) {
          return (address: initializedTonAddress, pkAsBytes: <int>[]);
        }
        _logger.logInfoMessage(
          _name,
          'tryInitializeWallet: reset wallet success. '
          'Old wallet: $initializedTonAddress',
        );
        _walletService = null;
        _jettonWallets.clear();
      }
      final pk = await _createSigningKeyOrThrow(masterKey: masterKey);
      _walletService = TonWalletService.fromPublicKey(
        tonChain: isTestnet ? TonChainId.testnet : TonChainId.mainnet,
        publicKey: pk.toPublicKey(),
        rpc: _rpc,
        logger: _logger,
      );
      return (
        address: _walletService!.tonWallet.address.toString(),
        pkAsBytes: pk.toBytes(),
      );
    } catch (e) {
      if (e is! IncorrectPinCodeException) {
        _logger.logCriticalError(_name, 'tryInitializeWallet: $e');
      }
      rethrow;
    }
  }

  Future<TonPrivateKey> _createSigningKeyOrThrow({
    required String masterKey,
  }) async {
    // Take the current active Tron wallet
    final mnemonicFromRepo = await _localRepo.getMnemonic(
      publicKey: _localRepo.getAccount().publicKey,
      masterKey: masterKey,
    );
    if (mnemonicFromRepo.isEmpty) {
      throw AppException(code: ExceptionCode.unableToRetrieveMnemonic);
    }
    return KeyGenerator(mnemonic: mnemonicFromRepo).generateForTon();
  }

  @override
  Future<bool?> checkWalletIsFrozen({
    required AppAsset asset,
    required String addressToCheck,
  }) async {
    try {
      final walletService =
          _walletService ??
          TonWalletService.fromWalletAddress(
            tonChain: isTestnet ? TonChainId.testnet : TonChainId.mainnet,
            address: asset.address,
            rpc: _rpc,
            logger: _logger,
          );
      final res = await walletService.fetchWalletAddressState(
        walletAddress: addressToCheck,
      );
      return res == TonAddressStateType.frozen;
    } catch (e) {
      _logger.logError(
        _name,
        'checkWalletIsFrozen: for wallet $addressToCheck. Exception: $e',
      );
      return null;
    }
  }
}
