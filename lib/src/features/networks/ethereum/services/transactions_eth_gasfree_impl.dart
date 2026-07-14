import 'dart:convert';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:on_chain/on_chain.dart' show ETHPrivateKey;
import 'package:permissionless/permissionless.dart' as pl;
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service (gasfree)
///
/// Creates gasfree ERC-20 transfers: an EIP-7702 UserOperation where gas is
/// paid in the transferred token itself via the Pimlico ERC-20 paymaster.
/// The sender needs NO native coin at all. The first operation additionally
/// installs the EIP-7702 delegation (the authorization is attached to the
/// same UserOperation).
///
/// [createTransaction] returns NOT a raw transaction: it is a ready-to-forward
/// JSON-RPC `eth_sendUserOperation` request body (String). The backend must
/// forward it VERBATIM to the Pimlico API for the corresponding chain (not to
/// a regular node) and poll `eth_getUserOperationReceipt` for the resulting
/// transaction hash.
class TransactionsServiceEthereumGasfreeImpl
    implements TransactionsService<TransferParamsGasfreeETH> {
  /// Transactions Service (gasfree)
  TransactionsServiceEthereumGasfreeImpl({
    required this.appBlockchain,
    required this.nodeApiUri,
    required this.pimlicoApiUri,
    required Future<String> Function(String masterKey) getSigningKey,
    String Function()? getAuthToken,
    TRLogger? logger,
    @visibleForTesting http.Client? httpClient,
  }) : _getSigningKey = getSigningKey,
       _getAuthToken = getAuthToken,
       _httpClient = httpClient,
       assert(
         TransactionsServiceEthereumImpl.supportedBlockchains.contains(
           appBlockchain,
         ),
         '$appBlockchain is not supported',
       ) {
    _logger = logger ?? InAppLogger();
  }

  /// Blockchain of the service
  @override
  final AppBlockchain appBlockchain;

  /// Regular node RPC (backend proxy) - public calls: delegation code,
  /// balances, EntryPoint nonce
  final String nodeApiUri;

  /// Pimlico API (backend proxy) base URI. The chain id is appended as the
  /// last path segment: `{pimlicoApiUri}/{chainId}` - bundler, paymaster and
  /// pimlico_* methods all go to this single URL
  final String pimlicoApiUri;

  /// Get the mnemonic for signing
  final Future<String> Function(String masterKey) _getSigningKey;

  /// Auth token for the backend proxies
  final String Function()? _getAuthToken;

  /// Injected http client for tests
  final http.Client? _httpClient;

  late final TRLogger _logger;

  String get _name =>
      'TransactionsServiceEthereumGasfreeImpl-${appBlockchain.slug}';

  Map<String, String> get _authHeaders {
    final token = _getAuthToken?.call();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Pimlico proxy URL for the chain: `{pimlicoApiUri}/{chainId}`
  @visibleForTesting
  String pimlicoUrlForChain(int chainId) {
    final base = pimlicoApiUri.endsWith('/')
        ? pimlicoApiUri.substring(0, pimlicoApiUri.length - 1)
        : pimlicoApiUri;
    return '$base/$chainId';
  }

  /// Create a gasfree UserOperation and return the `eth_sendUserOperation`
  /// JSON-RPC request body for the backend to forward to Pimlico
  ///
  /// THROWS
  @override
  Future<String> createTransaction({
    required TransferParamsGasfreeETH params,
    required String masterKey,
  }) async {
    if (params.amount <= BigRational.zero) {
      throw AppException(
        message:
            'unable to create transaction: amount is not valid: '
            '${params.amount}',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    // Gasfree применим только к токен-контрактам: master (нативная монета)
    // и unknown отбрасываем (assert в params работает только в debug)
    if (params.tokenWalletType == TokenWalletType.master ||
        params.tokenWalletType == TokenWalletType.unknown) {
      throw AppException(
        message:
            'gasfree is not applicable to token type '
            '${params.tokenWalletType}',
        code: ExceptionCode.wrongToken,
      );
    }
    final serviceFee = params.serviceFeeAmount ?? BigRational.zero;
    if (serviceFee < BigRational.zero) {
      throw AppException(
        message: 'service fee is negative: $serviceFee',
        code: ExceptionCode.invalidCommissionAmount,
      );
    }
    final collector = params.serviceFeeCollector ?? '';
    if (serviceFee > BigRational.zero && collector.isEmpty) {
      throw AppException(
        message: 'service fee collector is empty for fee $serviceFee',
        code: ExceptionCode.invalidCommissionAmount,
      );
    }

    final pk = await _createSigningKey(masterKey: masterKey);
    final owner = pl.PrivateKeyEip7702Owner(
      BytesUtils.toHexString(pk.toBytes(), prefix: '0x'),
    );

    final pimlicoUrl = pimlicoUrlForChain(params.chainId);
    final publicClient = pl.createPublicClient(
      url: nodeApiUri,
      httpClient: _httpClient,
      headers: _authHeaders,
    );
    final pimlico = pl.createPimlicoClient(
      url: pimlicoUrl,
      entryPoint: pl.EntryPointAddresses.v08,
      httpClient: _httpClient,
      headers: _authHeaders,
    );
    final client = pl.SmartAccountClient(
      account: pl.createEip7702SimpleSmartAccount(
        owner: owner,
        chainId: BigInt.from(params.chainId),
        publicClient: publicClient,
      ),
      bundler: pimlico,
      publicClient: publicClient,
      paymaster: pl.createPaymasterClient(
        url: pimlicoUrl,
        httpClient: _httpClient,
        headers: _authHeaders,
      ),
    );

    try {
      final token = pl.EthereumAddress.fromHex(params.tokenContractAddress!);

      // The token must be supported by the ERC-20 paymaster (the check is
      // done upfront to convert the case into a typed AppException)
      final quotes = await pimlico.getTokenQuotes([token]);
      if (quotes.isEmpty) {
        throw AppException(
          message:
              'token ${params.tokenName ?? token.hex} is not supported '
              'by the ERC-20 paymaster on chain ${params.chainId}',
          code: ExceptionCode.tokenIsNotSupported,
        );
      }

      final amountRaw = DecimalConverter.toBigInt(
        amount: params.amount.toString(),
        decimals: params.tokenDecimal,
      );
      final serviceFeeRaw = serviceFee > BigRational.zero
          ? DecimalConverter.toBigInt(
              amount: serviceFee.toString(),
              decimals: params.tokenDecimal,
            )
          : BigInt.zero;

      final calls = [
        pl.encodeErc20Transfer(
          token: token,
          to: pl.EthereumAddress.fromHex(params.to),
          amount: amountRaw,
        ),
        if (serviceFeeRaw > BigInt.zero)
          pl.encodeErc20Transfer(
            token: token,
            to: pl.EthereumAddress.fromHex(collector),
            amount: serviceFeeRaw,
          ),
      ];

      final gasPrices = await pimlico.getUserOperationGasPrice();

      // TODO(gasfree): compare the max cost against the fee approved by the
      // user (backend estimateFee) once the backend contract for the expected
      // vs max fee is settled - the AppFeeChangedException pattern
      final result = await pl.prepareUserOperationForErc20Paymaster(
        smartAccountClient: client,
        pimlicoClient: pimlico,
        publicClient: publicClient,
        token: token,
        calls: calls,
        maxFeePerGas: gasPrices.fast.maxFeePerGas,
        maxPriorityFeePerGas: gasPrices.fast.maxPriorityFeePerGas,
      );

      // The paymaster approves itself for the MAX cost: if the token balance
      // does not cover transfers + max gas cost, the bundler rejects the op
      // during simulation with an obscure revert - fail fast with a typed
      // exception instead
      final sender = pl.EthereumAddress.fromHex(params.from);
      final balanceRaw = pl.decodeUint256Result(
        await publicClient.call(
          pl.Call(
            to: token,
            data: pl.encodeErc20BalanceOfCall(account: sender),
          ),
        ),
      );
      final totalNeeded = amountRaw + serviceFeeRaw + result.maxCostInToken;
      if (balanceRaw < totalNeeded) {
        throw AppException(
          message:
              'insufficient token balance: have $balanceRaw, need '
              '$totalNeeded (amount $amountRaw + service fee $serviceFeeRaw '
              '+ max gas cost ${result.maxCostInToken})',
          code: ExceptionCode.insufficientBalance,
        );
      }

      _logger.logInfoMessage(
        _name,
        'gasfree op prepared: to: ${params.to}, amount: ${params.amount}'
        '${params.tokenName != null ? ', token: ${params.tokenName}' : ''}, '
        'maxCostInToken: ${result.maxCostInToken}, '
        'serviceFee: $serviceFee, '
        'firstTimeDelegation: ${result.authorization != null}',
      );

      final signedOp = await client.signUserOperation(result.userOperation);

      final userOpJson = signedOp.toJson();
      if (result.authorization != null) {
        userOpJson['eip7702Auth'] = result.authorization!.toRpcFormat();
      }
      return jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'eth_sendUserOperation',
        'params': [userOpJson, pl.EntryPointAddresses.v08.hex],
      });
    } on pl.BundlerRpcError catch (e) {
      throw AppException(
        message: 'bundler/paymaster error: ${e.message}',
        code: ExceptionCode.rpcError,
      );
    } finally {
      // client.close() closes both the bundler (pimlico) and the paymaster
      client.close();
      publicClient.close();
    }
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

  @override
  Future<bool> checkWalletIsFrozen({
    required String assetAddress,
    required String addressToCheck,
  }) async => false;

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
}
