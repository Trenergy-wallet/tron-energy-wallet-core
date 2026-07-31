import 'dart:convert';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:on_chain/on_chain.dart' show ETHPrivateKey;
import 'package:permissionless/permissionless.dart' as pl;
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Transactions Service (gasFree)
///
/// Creates gasFree ERC-20 transfers: an EIP-7702 UserOperation where gas is
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
class TransactionsServiceEthereumGasFreeImpl
    implements TransactionsService<TransferParamsGasFreeETH> {
  /// Transactions Service (gasFree)
  TransactionsServiceEthereumGasFreeImpl({
    required this.appBlockchain,
    required this.nodeApiUri,
    required this.pimlicoApiUri,
    required Future<String> Function(String masterKey) getSigningKey,
    this.getHeaders,
    TRLogger? logger,
    // Custom http client - for tests and diagnostics (call counting)
    http.Client? httpClient,
  }) : _getSigningKey = getSigningKey,
       _logger = logger,
       _injectedHttpClient = httpClient,
       assert(
         appBlockchain.isEvm,
         '$appBlockchain is not supported',
       );

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

  /// Headers for the backend proxies
  final Map<String, String>? Function()? getHeaders;

  /// Http client injected via the constructor (tests / call counting), shared
  /// across all sub-clients. Null in production
  final http.Client? _injectedHttpClient;

  /// A fresh http client for every permissionless sub-client.
  ///
  /// permissionless closes the client it is given once an operation completes,
  /// so a single long-lived shared instance breaks on the next round with
  /// "Client is already closed". Returns the injected client as is when
  /// provided (tests manage its lifecycle), a fresh logging wrapper when a
  /// logger is set, or null so permissionless creates its own plain client
  http.Client? get _newHttpClient =>
      _injectedHttpClient ??
      (_logger == null
          ? null
          : LoggingHttpClient(http.Client(), logger: _logger));

  /// Logger - null when the caller did not provide one (no logging)
  final TRLogger? _logger;

  String get _name =>
      'TransactionsServiceEthereumGasFreeImpl-${appBlockchain.slug}';

  Map<String, String>? get _requestHeaders => getHeaders?.call();

  /// Pimlico proxy URL for the chain
  ///
  /// If [pimlicoApiUri] contains the `{chainId}` placeholder - substitute it
  /// (handy for a direct Pimlico URL `https://api.pimlico.io/v2/{chainId}/rpc?apikey=..`).
  /// If the chain segment is already in the path (a full single-chain URL
  /// was provided) - use as is. Otherwise chainId is appended as the last
  /// path segment, query parameters (e.g. apikey) are preserved
  @visibleForTesting
  String pimlicoUrlForChain(int chainId) {
    if (pimlicoApiUri.contains('{chainId}')) {
      return pimlicoApiUri.replaceAll('{chainId}', '$chainId');
    }
    final uri = Uri.parse(pimlicoApiUri);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    // The chain is already in the path - do not duplicate
    if (segments.contains('$chainId')) return pimlicoApiUri;
    return uri.replace(pathSegments: [...segments, '$chainId']).toString();
  }

  /// Create a gasFree UserOperation and return the `eth_sendUserOperation`
  /// JSON-RPC request body for the backend to forward to Pimlico
  ///
  /// THROWS
  @override
  Future<String> createTransaction({
    required TransferParamsGasFreeETH params,
    required String masterKey,
  }) async {
    final serviceFee = _validateTransferParams(params);
    final collector = params.serviceFeeCollector ?? '';

    final pk = await _createSigningKey(masterKey: masterKey);
    final owner = pl.PrivateKeyEip7702Owner(
      BytesUtils.toHexString(pk.toBytes(), prefix: '0x'),
    );

    final pimlicoUrl = pimlicoUrlForChain(params.chainId);
    final publicClient = pl.createPublicClient(
      url: nodeApiUri,
      httpClient: _newHttpClient,
      headers: _requestHeaders,
      timeout: CoreConsts.defaultRequestTimeout,
    );
    final pimlico = pl.createPimlicoClient(
      url: pimlicoUrl,
      entryPoint: pl.EntryPointAddresses.v08,
      httpClient: _newHttpClient,
      headers: _requestHeaders,
      timeout: CoreConsts.defaultRequestTimeout,
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
        httpClient: _newHttpClient,
        headers: _requestHeaders,
        timeout: CoreConsts.defaultRequestTimeout,
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

      final amountRaw = UnitsConverter.tokenToUnits(
        amount: params.amount,
        decimals: params.tokenDecimal,
      );
      final serviceFeeRaw = serviceFee > BigRational.zero
          ? UnitsConverter.tokenToUnits(
              amount: serviceFee,
              decimals: params.tokenDecimal,
            )
          : BigInt.zero;

      final calls = [
        pl.encodeErc20Transfer(
          token: token,
          to: pl.EthereumAddress.fromHex(params.to),
          amount: amountRaw,
        ),
        // Collector transfer only for a positive fee AND a valid address
        // (validation above guarantees it, the guard is duplicated locally)
        if (serviceFeeRaw > BigInt.zero && collector.isNotEmpty)
          pl.encodeErc20Transfer(
            token: token,
            to: pl.EthereumAddress.fromHex(collector),
            amount: serviceFeeRaw,
          ),
      ];

      final gasPrices = await pimlico.getUserOperationGasPrice();

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
      _logger?.logInfoMessage(
        _name,
        'gasFree op prepared: to: ${params.to}, amount: ${params.amount}'
        '${params.tokenName != null ? ', token: ${params.tokenName}' : ''}, '
        'maxCostInToken: ${result.maxCostInToken}, '
        'serviceFee: $serviceFee, '
        'firstTimeDelegation: ${result.authorization != null}',
      );

      final signedOp = await client.signUserOperation(result.userOperation);

      return _sendUserOperationPayload(signedOp, result.authorization);
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

  /// Well-known test key (hardhat account #0) - used ONLY to encode the
  /// calldata and the stub signature during estimation (pure functions),
  /// a signature by this key is never verified or submitted anywhere
  static const _dummyOwnerKey =
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

  /// Fake signature component of the dummy authorization (32 bytes)
  static const _dummySigComponent =
      '0x0000000000000000000000000000000000000000000000000000000000000001';

  /// Mainnet USDT requires resetting the approve to 0 before a new one
  static const _mainnetUsdtAddress =
      '0xdac17f958d2ee523a2206206994597c13d831ec7';

  /// Precise gasFree operation estimation WITHOUT the private key
  ///
  /// One paid Pimlico round: token quote + gas prices + paymaster stub +
  /// eth_estimateUserOperationGas. The result is cacheable
  /// ([GasfreeEstimate]): gas limits do not depend on the amount, so the
  /// estimate survives the whole amount input, and sending from it
  /// ([createTransactionFromEstimate]) costs exactly one paid call
  ///
  /// For the first operation (delegation not installed yet) a dummy
  /// authorization goes into the estimation: the signature is fake and is
  /// not verified during simulation
  ///
  /// [serviceFeeCollector] - non-empty address: an extra service fee
  /// transfer is included into the estimation calldata; null or an empty
  /// string - no service fee
  ///
  /// THROWS
  Future<GasfreeEstimate> estimateGasFree({
    required int chainId,
    required String senderAddress,
    required String recipientAddress,
    required String tokenContractAddress,
    required int tokenDecimal,
    String? serviceFeeCollector,
  }) async {
    // An empty string is equivalent to no service fee
    final collector = (serviceFeeCollector?.isNotEmpty ?? false)
        ? serviceFeeCollector
        : null;
    final pimlicoUrl = pimlicoUrlForChain(chainId);
    final publicClient = pl.createPublicClient(
      url: nodeApiUri,
      httpClient: _newHttpClient,
      headers: _requestHeaders,
      timeout: CoreConsts.defaultRequestTimeout,
    );
    final pimlico = pl.createPimlicoClient(
      url: pimlicoUrl,
      entryPoint: pl.EntryPointAddresses.v08,
      httpClient: _newHttpClient,
      headers: _requestHeaders,
      timeout: CoreConsts.defaultRequestTimeout,
    );
    final paymaster = pl.createPaymasterClient(
      url: pimlicoUrl,
      httpClient: _newHttpClient,
      headers: _requestHeaders,
      timeout: CoreConsts.defaultRequestTimeout,
    );
    // Account with the well-known dummy key: needed only to encode the
    // calldata and the stub signature - no real key required for estimation
    final dummyAccount = pl.createEip7702SimpleSmartAccount(
      owner: pl.PrivateKeyEip7702Owner(_dummyOwnerKey),
      chainId: BigInt.from(chainId),
      publicClient: publicClient,
    );

    try {
      final token = pl.EthereumAddress.fromHex(tokenContractAddress);
      final sender = pl.EthereumAddress.fromHex(senderAddress);

      final quotes = await pimlico.getTokenQuotes([token]);
      if (quotes.isEmpty) {
        throw AppException(
          message:
              'token $tokenContractAddress is not supported by the '
              'ERC-20 paymaster on chain $chainId',
          code: ExceptionCode.tokenIsNotSupported,
        );
      }
      final quote = quotes.first;
      final prices = await pimlico.getUserOperationGasPrice();

      // Free node calls: delegation status and nonces
      final delegation = _delegationState(
        await publicClient.getCode(sender),
      );
      final accountNonce = await publicClient.getAccountNonce(
        sender,
        pl.EntryPointAddresses.v08,
      );

      // Dummy authorization for the first operation: real EOA nonce,
      // fake signature
      pl.Eip7702Authorization? authorization;
      if (delegation.needsDelegation) {
        final eoaNonce = await publicClient.getTransactionCount(sender);
        authorization = pl.Eip7702Authorization(
          chainId: BigInt.from(chainId),
          address: pl.Simple7702AccountAddresses.defaultLogic,
          nonce: eoaNonce,
          v: 27,
          r: _dummySigComponent,
          s: _dummySigComponent,
        );
      }

      // Estimation calldata: dummy max approve + transfer(s) of 1 base
      // unit. Gas limits barely depend on the amount value, and a minimal
      // amount does not revert on balance during simulation
      final isMainnetUsdt = token.hex.toLowerCase() == _mainnetUsdtAddress;
      final estimationCalls = [
        if (isMainnetUsdt)
          pl.encodeErc20Approve(
            token: token,
            spender: quote.paymaster,
            amount: BigInt.zero,
          ),
        pl.encodeErc20Approve(
          token: token,
          spender: quote.paymaster,
          amount: pl.maxUint256,
        ),
        pl.encodeErc20Transfer(
          token: token,
          to: pl.EthereumAddress.fromHex(recipientAddress),
          amount: BigInt.one,
        ),
        if (collector != null)
          pl.encodeErc20Transfer(
            token: token,
            to: pl.EthereumAddress.fromHex(collector),
            amount: BigInt.one,
          ),
      ];

      var userOp = pl.UserOperationV07(
        sender: sender,
        nonce: accountNonce,
        factory: delegation.needsDelegation && !delegation.hasCode
            ? pl.eip7702FactoryMarkerAddress
            : null,
        factoryData: delegation.needsDelegation && !delegation.hasCode
            ? '0x'
            : null,
        callData: dummyAccount.encodeCalls(estimationCalls),
        callGasLimit: BigInt.zero,
        verificationGasLimit: BigInt.zero,
        preVerificationGas: BigInt.zero,
        maxFeePerGas: prices.fast.maxFeePerGas,
        maxPriorityFeePerGas: prices.fast.maxPriorityFeePerGas,
        signature: dummyAccount.getStubSignature(),
      );

      final stub = await paymaster.getPaymasterStubData(
        userOp: userOp,
        entryPoint: pl.EntryPointAddresses.v08,
        chainId: BigInt.from(chainId),
        context: pl.PaymasterContext(token: token),
        authorization: authorization,
      );
      userOp = userOp.withPaymasterStub(stub);

      final gasEstimate = authorization != null
          ? await pimlico.estimateUserOperationGasWithAuthorization(
              userOp,
              [authorization],
            )
          : await pimlico.estimateUserOperationGas(userOp);

      final paymasterVerificationGasLimit =
          gasEstimate.paymasterVerificationGasLimit ??
          stub.paymasterVerificationGasLimit ??
          BigInt.zero;
      final paymasterPostOpGasLimit =
          gasEstimate.paymasterPostOpGasLimit ??
          stub.paymasterPostOpGasLimit ??
          BigInt.zero;

      final gasSum =
          gasEstimate.preVerificationGas +
          gasEstimate.verificationGasLimit +
          gasEstimate.callGasLimit +
          paymasterVerificationGasLimit +
          paymasterPostOpGasLimit +
          quote.postOpGas;

      // Pimlico paymaster formula:
      // costInToken = (gas x gasPrice x exchangeRate) / 1e18
      final oneEth = BigInt.from(10).pow(18);
      // The maximum is reserved at the fast price - the approve is given
      // for this amount
      final maxCostInToken =
          gasSum * prices.fast.maxFeePerGas * quote.exchangeRate ~/ oneEth;
      // The expected one (for display) - at the standard price
      final expectedRaw =
          gasSum * prices.standard.maxFeePerGas * quote.exchangeRate ~/ oneEth;
      final expectedFeeInToken =
          BigRational(expectedRaw) /
          BigRational(BigInt.from(10).pow(tokenDecimal));

      _logger?.logInfoMessage(
        _name,
        'gasFree estimated: sender: $senderAddress, gasSum: $gasSum, '
        'needsDelegation: ${delegation.needsDelegation}, '
        'expectedFee: $expectedFeeInToken, maxCostInToken: $maxCostInToken',
      );

      return GasfreeEstimate(
        chainId: chainId,
        senderAddress: senderAddress,
        tokenContractAddress: tokenContractAddress,
        includesServiceFee: collector != null,
        paymasterAddress: quote.paymaster.hex,
        stubPaymasterData: stub.paymasterData,
        exchangeRate: quote.exchangeRate,
        postOpGas: quote.postOpGas,
        callGasLimit: gasEstimate.callGasLimit,
        verificationGasLimit: gasEstimate.verificationGasLimit,
        preVerificationGas: gasEstimate.preVerificationGas,
        paymasterVerificationGasLimit: paymasterVerificationGasLimit,
        paymasterPostOpGasLimit: paymasterPostOpGasLimit,
        maxFeePerGas: prices.fast.maxFeePerGas,
        maxPriorityFeePerGas: prices.fast.maxPriorityFeePerGas,
        needsDelegation: delegation.needsDelegation,
        maxCostInToken: maxCostInToken,
        expectedFeeInToken: expectedFeeInToken,
        createdAt: DateTime.now(),
      );
    } on pl.BundlerRpcError catch (e) {
      throw AppException(
        message: 'bundler/paymaster error: ${e.message}',
        code: ExceptionCode.rpcError,
      );
    } finally {
      pimlico.close();
      paymaster.close();
      publicClient.close();
    }
  }

  /// Creates a gasFree transaction from a precomputed estimate
  ///
  /// Exactly ONE paid call (the final pm_getPaymasterData), everything else
  /// is free node calls and local assembly from [estimate].
  /// The estimate must match the params (sender, chain, token, service fee
  /// presence), its freshness is controlled by the caller
  ///
  /// THROWS
  Future<String> createTransactionFromEstimate({
    required TransferParamsGasFreeETH params,
    required GasfreeEstimate estimate,
    required String masterKey,
  }) async {
    final serviceFee = _validateTransferParams(params);
    final collector = params.serviceFeeCollector ?? '';

    // The estimate must match the transfer params
    final matchesParams =
        estimate.chainId == params.chainId &&
        estimate.senderAddress.toLowerCase() == params.from.toLowerCase() &&
        estimate.tokenContractAddress.toLowerCase() ==
            params.tokenContractAddress!.toLowerCase() &&
        estimate.includesServiceFee == (serviceFee > BigRational.zero);
    if (!matchesParams) {
      throw AppException(
        message:
            'gasFree estimate does not match the transfer params: '
            '$estimate vs from: ${params.from}, chainId: ${params.chainId}, '
            'token: ${params.tokenContractAddress}, serviceFee: $serviceFee',
        code: ExceptionCode.unableToCreateTransaction,
      );
    }

    final pk = await _createSigningKey(masterKey: masterKey);
    final owner = pl.PrivateKeyEip7702Owner(
      BytesUtils.toHexString(pk.toBytes(), prefix: '0x'),
    );

    final publicClient = pl.createPublicClient(
      url: nodeApiUri,
      httpClient: _newHttpClient,
      headers: _requestHeaders,
      timeout: CoreConsts.defaultRequestTimeout,
    );
    final paymaster = pl.createPaymasterClient(
      url: pimlicoUrlForChain(params.chainId),
      httpClient: _newHttpClient,
      timeout: CoreConsts.defaultRequestTimeout,
    );
    final account = pl.createEip7702SimpleSmartAccount(
      owner: owner,
      chainId: BigInt.from(params.chainId),
      publicClient: publicClient,
    );

    try {
      final token = pl.EthereumAddress.fromHex(params.tokenContractAddress!);
      final amountRaw = UnitsConverter.tokenToUnits(
        amount: params.amount,
        decimals: params.tokenDecimal,
      );
      final serviceFeeRaw = serviceFee > BigRational.zero
          ? UnitsConverter.tokenToUnits(
              amount: serviceFee,
              decimals: params.tokenDecimal,
            )
          : BigInt.zero;

      final transfers = [
        pl.encodeErc20Transfer(
          token: token,
          to: pl.EthereumAddress.fromHex(params.to),
          amount: amountRaw,
        ),
        // Collector transfer only for a positive fee AND a valid address
        // (validation above guarantees it, the guard is duplicated locally)
        if (serviceFeeRaw > BigInt.zero && collector.isNotEmpty)
          pl.encodeErc20Transfer(
            token: token,
            to: pl.EthereumAddress.fromHex(collector),
            amount: serviceFeeRaw,
          ),
      ];

      // Balance guard before the paid call and signing
      final senderAddress = await account.getAddress();
      final balanceRaw = pl.decodeUint256Result(
        await publicClient.call(
          pl.Call(
            to: token,
            data: pl.encodeErc20BalanceOfCall(account: senderAddress),
          ),
        ),
      );
      final totalNeeded = amountRaw + serviceFeeRaw + estimate.maxCostInToken;
      if (balanceRaw < totalNeeded) {
        throw AppException(
          message:
              'insufficient token balance: have $balanceRaw, need '
              '$totalNeeded (amount $amountRaw + service fee $serviceFeeRaw '
              '+ max gas cost ${estimate.maxCostInToken})',
          code: ExceptionCode.insufficientBalance,
        );
      }

      final result = await finalizeUserOperationFromEstimate(
        account: account,
        publicClient: publicClient,
        paymaster: paymaster,
        transfers: transfers,
        estimate: estimate,
      );

      _logger?.logInfoMessage(
        _name,
        'gasFree op finalized from estimate: to: ${params.to}, '
        'amount: ${params.amount}'
        '${params.tokenName != null ? ', token: ${params.tokenName}' : ''}, '
        'maxCostInToken: ${estimate.maxCostInToken}, '
        'serviceFee: $serviceFee, '
        'firstTimeDelegation: ${result.authorization != null}',
      );

      final signature = await account.signUserOperation(result.userOperation);
      final signedOp = result.userOperation.copyWith(signature: signature);

      return _sendUserOperationPayload(signedOp, result.authorization);
    } on pl.BundlerRpcError catch (e) {
      throw AppException(
        message: 'bundler/paymaster error: ${e.message}',
        code: ExceptionCode.rpcError,
      );
    } finally {
      paymaster.close();
      publicClient.close();
    }
  }

  /// Assembles the final UserOperation from a precomputed estimate
  ///
  /// Upstream permissionless candidate: an analog of
  /// prepareUserOperationForErc20Paymaster, but the quote/limits/prices come
  /// from a ready estimate - exactly one paid call remains
  /// (pm_getPaymasterData). Free node calls: nonce, delegation status,
  /// allowance
  @visibleForTesting
  Future<
    ({
      pl.UserOperationV07 userOperation,
      pl.Eip7702Authorization? authorization,
    })
  >
  finalizeUserOperationFromEstimate({
    required pl.Eip7702SimpleSmartAccount account,
    required pl.PublicClient publicClient,
    required pl.PaymasterClient paymaster,
    required List<pl.Call> transfers,
    required GasfreeEstimate estimate,
  }) async {
    final token = pl.EthereumAddress.fromHex(estimate.tokenContractAddress);
    final paymasterAddress = pl.EthereumAddress.fromHex(
      estimate.paymasterAddress,
    );
    final sender = await account.getAddress();

    // Free node calls: account nonce, delegation status, allowance
    final accountNonce = await publicClient.getAccountNonce(
      sender,
      account.entryPoint,
    );
    final delegation = _delegationState(await publicClient.getCode(sender));

    pl.Eip7702Authorization? authorization;
    if (delegation.needsDelegation) {
      final eoaNonce = await publicClient.getTransactionCount(sender);
      authorization = await account.getAuthorization(nonce: eoaNonce);
    }

    final currentAllowance = pl.decodeUint256Result(
      await publicClient.call(
        pl.Call(
          to: token,
          data: pl.encodeErc20AllowanceCall(
            owner: sender,
            spender: paymasterAddress,
          ),
        ),
      ),
    );

    // Approve for exactly maxCostInToken when the current allowance is
    // not enough.
    //
    // The ERC-20 semantics we rely on here:
    // - approve(spender, X) OVERWRITES the allowance with X, it does not
    //   add to it - hence the full required value, an approve "for the
    //   difference" would produce an insufficient allowance;
    // - approve requires no balance and reserves no funds (it is a number
    //   written to storage), allowance > balance is a legal state; the
    //   balance is only needed for the paymaster charge itself (postOp
    //   transferFrom of the ACTUAL cost <= maxCostInToken), covered by the
    //   balance guard balance >= amount + serviceFee + maxCostInToken up
    //   the stack;
    // - an unspent allowance remainder is reused by subsequent operations
    //   (no approve is needed then at all), and on overwrite the previous
    //   allowance tail is not summed up - deliberately: the allowance is
    //   kept no higher than the max of the current operation
    final isMainnetUsdt = token.hex.toLowerCase() == _mainnetUsdtAddress;
    final finalCalls = [
      if (currentAllowance < estimate.maxCostInToken) ...[
        if (isMainnetUsdt)
          pl.encodeErc20Approve(
            token: token,
            spender: paymasterAddress,
            amount: BigInt.zero,
          ),
        pl.encodeErc20Approve(
          token: token,
          spender: paymasterAddress,
          amount: estimate.maxCostInToken,
        ),
      ],
      ...transfers,
    ];

    var userOp = pl.UserOperationV07(
      sender: sender,
      nonce: accountNonce,
      // The factory marker is only for the first delegation on a fresh
      // address, re-delegation goes without it (the
      // prepareUserOperationWithAuth rule)
      factory: delegation.needsDelegation && !delegation.hasCode
          ? pl.eip7702FactoryMarkerAddress
          : null,
      factoryData: delegation.needsDelegation && !delegation.hasCode
          ? '0x'
          : null,
      callData: account.encodeCalls(finalCalls),
      callGasLimit: estimate.callGasLimit,
      verificationGasLimit: estimate.verificationGasLimit,
      preVerificationGas: estimate.preVerificationGas,
      maxFeePerGas: estimate.maxFeePerGas,
      maxPriorityFeePerGas: estimate.maxPriorityFeePerGas,
      paymaster: paymasterAddress,
      paymasterData: estimate.stubPaymasterData,
      paymasterVerificationGasLimit: estimate.paymasterVerificationGasLimit,
      paymasterPostOpGasLimit: estimate.paymasterPostOpGasLimit,
      signature: account.getStubSignature(),
    );

    // The only paid call: the paymaster signs over the final calldata
    final finalData = await paymaster.getPaymasterData(
      userOp: userOp,
      entryPoint: account.entryPoint,
      chainId: account.chainId,
      context: pl.PaymasterContext(token: token),
      authorization: authorization,
    );
    userOp = userOp.withPaymasterData(finalData);

    return (userOperation: userOp, authorization: authorization);
  }

  /// Validates the gasFree transfer params
  ///
  /// Returns the service fee (zero = disabled)
  ///
  /// THROWS
  BigRational _validateTransferParams(TransferParamsGasFreeETH params) {
    if (params.amount <= BigRational.zero) {
      throw AppException(
        message:
            'unable to create transaction: amount is not valid: '
            '${params.amount}',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    // Gasfree is applicable to token contracts only: master (native coin)
    // and unknown are rejected (the assert in params works in debug only)
    if (params.tokenWalletType == TokenWalletType.master ||
        params.tokenWalletType == TokenWalletType.unknown) {
      throw AppException(
        message:
            'gasFree is not applicable to token type '
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
    // An empty/invalid collector address with a positive fee - a typed
    // error here instead of a FormatException from fromHex during
    // calldata assembly
    if (serviceFee > BigRational.zero &&
        !_evmAddressRegExp.hasMatch(collector)) {
      throw AppException(
        message:
            'service fee collector is not a valid address: "$collector" '
            'for fee $serviceFee',
        code: ExceptionCode.invalidCommissionAmount,
      );
    }
    return serviceFee;
  }

  /// EVM address format: 0x + 40 hex chars
  static final _evmAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');

  /// EIP-7702 delegation status by the code at the address
  ///
  /// needsDelegation - the code is empty, foreign, or the delegation does
  /// not point to Simple7702Account
  /// hasCode - the address has any code (affects the factory marker)
  ({bool needsDelegation, bool hasCode}) _delegationState(String code) {
    final c = code.toLowerCase();
    final hasCode = c != '0x' && c.isNotEmpty;
    if (c.length >= 48 && c.startsWith('0xef0100')) {
      final delegated = '0x${c.substring(8, 48)}';
      final expected = pl.Simple7702AccountAddresses.defaultLogic.hex
          .toLowerCase();
      return (needsDelegation: delegated != expected, hasCode: true);
    }
    return (needsDelegation: true, hasCode: hasCode);
  }

  /// Ready-to-forward `eth_sendUserOperation` JSON-RPC body for the
  /// backend to relay
  String _sendUserOperationPayload(
    pl.UserOperationV07 signedOp,
    pl.Eip7702Authorization? authorization,
  ) {
    final userOpJson = signedOp.toJson();
    if (authorization != null) {
      userOpJson['eip7702Auth'] = authorization.toRpcFormat();
    }
    return jsonEncode({
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'eth_sendUserOperation',
      'params': [userOpJson, pl.EntryPointAddresses.v08.hex],
    });
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
