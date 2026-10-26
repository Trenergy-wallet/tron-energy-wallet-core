import 'dart:async';

import 'package:ton_dart/ton_dart.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tr_ton_wallet_service/tr_ton_wallet_service.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service
///
/// Provides services for creating and signing transactions
class TransactionsServiceTonImpl
    implements TransactionsService<TransferParamsTON> {
  /// Transactions Service
  ///
  /// Provides services for creating and signing transactions
  TransactionsServiceTonImpl({
    required String? Function() currentAccountWallet,
    required Future<String> Function(String masterKey) getSigningKey,
    required this.isTestnet,
    required this.rpc,
    TRLogger? logger,
  }) : _getSigningKey = getSigningKey,
       _currentAccountWallet = currentAccountWallet {
    _logger = logger ?? InAppLogger();
  }

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain = AppBlockchain.ton;

  /// Network for which the initialization was completed
  final bool isTestnet;

  final String? Function() _currentAccountWallet;

  /// Get Tron private key as String
  final Future<String> Function(String masterKey) _getSigningKey;

  /// TON Wallet service
  TonWalletService? _walletService;

  /// Node provider
  ///
  /// Long-lived, owned by the caller: the service never recreates it, so its
  /// http client keeps connections alive. The auth token must not be baked
  /// into it - [TonHTTPProvider] reads it via `getAuthToken` on every request
  final TonProvider rpc;

  static const String _name = 'TransactionsServiceTonImpl';

  late final TRLogger _logger;

  /// Jetton wallets
  final Map<int, TonJettonWalletService> _jettonWallets = {};

  @override
  Future<String> createTransaction({
    required TransferParamsTON params,
    required String masterKey,
  }) async {
    String? signedTransaction;
    if (!params.amount.isPositive) {
      throw AppException(
        message:
            'unable to create transaction: amount is not valid:'
            ' ${params.amount}',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    final walletInfo = await initializeWalletAndGetInfo(
      masterKey: masterKey,
    );
    // Failed to initialize the service, exiting
    if (_walletService == null) {
      throw AppException(
        message: 'Initialisation error for walletService',
        code: ExceptionCode.unableToInitializeWalletService,
      );
    }
    // If the key is provided, use it directly
    final key = walletInfo.pkAsBytes.isEmpty
        ? await _createSigningKey(masterKey: masterKey)
        : TonPrivateKey.fromBytes(walletInfo.pkAsBytes);
    switch (params.tokenWalletType) {
      case TokenWalletType.master:
        signedTransaction = await _walletService?.createTransfer(
          accessKey: key,
          addressTo: params.to,
          amount: params.amount.toString(),
          message: params.message,
          sendToBlockchain: false,
        );
      case TokenWalletType.child:
        var jettonWalletService = _jettonWallets[params.coinInfo.id];
        if (params.coinInfo.childWalletAddress.isEmpty) {
          throw AppException(
            message:
                'No jettonWalletAddress provided for master '
                'wallet ${params.from}',
            code: ExceptionCode.noJettonWallet,
          );
        }
        jettonWalletService ??= await _walletService?.openJettonWallet(
          jettonContractAddress: params.coinInfo.contractAddress,
          jettonWalletAddress: params.coinInfo.childWalletAddress,
          jettonOnChainMetadata: JettonOnChainMetadata.snakeFormat(
            name: params.coinInfo.name,
            image: params.coinInfo.icon,
            symbol: params.coinInfo.shortName,
            decimals: params.coinInfo.decimal,
          ),
        );
        if (jettonWalletService == null) {
          throw AppException(
            message:
                'Unable to initialise jetton service for '
                'token ${params.coinInfo.name}',
            code: ExceptionCode.unableToInitializeWalletService,
          );
        }
        _jettonWallets[params.coinInfo.id] = jettonWalletService;
        signedTransaction = await jettonWalletService.sendJettons(
          key: key,
          amount: params.amount.toString(),
          recipient: TonAddressParser.parse(params.to),
          sendToBlockchain: false,
          message: params.message,
        );
      case TokenWalletType.stable:
      case TokenWalletType.unknown:
        throw AppException(
          message: '${params.tokenWalletType} is not supported',
          code: ExceptionCode.tokenIsNotSupported,
        );
    }
    if (signedTransaction == null || signedTransaction.isEmpty) {
      throw AppException(code: ExceptionCode.unableToCreateTransaction);
    }
    return signedTransaction;
  }

  /// Wallet initialization check
  ///
  /// String address = success
  /// null = failure
  /// THROWS
  @override
  Future<({String address, List<int> pkAsBytes})> initializeWalletAndGetInfo({
    required String masterKey,
  }) async {
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
    final pk = await _createSigningKey(masterKey: masterKey);
    _walletService = TonWalletService.fromPublicKey(
      tonChain: isTestnet ? TonChainId.testnet : TonChainId.mainnet,
      publicKey: pk.toPublicKey(),
      rpc: rpc,
      logger: _logger,
    );
    return (
      address: _walletService!.tonWallet.address.toString(),
      pkAsBytes: pk.toBytes(),
    );
  }

  Future<TonPrivateKey> _createSigningKey({
    required String masterKey,
  }) async {
    // Take the current active Tron wallet
    final mnemonicFromRepo = await _getSigningKey(masterKey);
    if (mnemonicFromRepo.isEmpty) {
      throw AppException(code: ExceptionCode.unableToRetrieveMnemonic);
    }
    return KeyGenerator(mnemonic: mnemonicFromRepo).generateForTon();
  }

  @override
  Future<bool?> checkWalletIsFrozen({
    required String assetAddress,
    required String addressToCheck,
  }) async {
    try {
      final walletService =
          _walletService ??
          TonWalletService.fromWalletAddress(
            tonChain: isTestnet ? TonChainId.testnet : TonChainId.mainnet,
            address: assetAddress,
            rpc: rpc,
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
