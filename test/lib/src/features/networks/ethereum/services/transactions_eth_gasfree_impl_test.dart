import 'dart:convert';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Standard BIP-39 test vector, NOT a real wallet
const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

/// Address derived from [_testMnemonic] via m/44'/60'/0'/0/0
const _senderAddress = '0x9858EfFD232B4033E47d90003D41EC34EcaEda94';

const _tokenAddress = '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238';
const _recipientAddress = '0x57Be4787b25ed040b69677B57D7Db565e174Aa97';
const _collectorAddress = '0x1111111111111111111111111111111111111111';
const _paymasterAddress = '0x888888888888Ec68A58AB8094Cc1AD20Ba3D2402';
const _entryPointV08 = '0x4337084d9e255ff0702461cf8895ce9e3b5ff108';

/// Simple7702Account logic contract (eth-infinitism v0.8) — the delegate the
/// library expects an already-delegated EOA to point to
const _delegateNo0x = 'e6cae83bde06e4c305530e199d7217f42808555b';

String _uint256(BigInt value) =>
    '0x${value.toRadixString(16).padLeft(64, '0')}';

/// Mock of the node + Pimlico proxy JSON-RPC (all methods are distinct, so a
/// single client serves both URLs)
MockClient _mockRpc({
  bool delegated = false,
  BigInt? balance,
  bool tokenSupported = true,
  bool failEstimate = false,
  String estimateErrorMessage = 'estimation failed',
  List<Map<String, dynamic>>? log,
}) => MockClient((request) async {
  final body = jsonDecode(request.body) as Map<String, dynamic>;
  log?.add({'url': request.url.toString(), ...body});
  final method = body['method'] as String;

  if (failEstimate && method == 'eth_estimateUserOperationGas') {
    return http.Response(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': body['id'],
        'error': {'code': -32500, 'message': estimateErrorMessage},
      }),
      200,
    );
  }

  final result = switch (method) {
    'eth_chainId' => '0xaa36a7',
    // 7702: empty code = not delegated yet, otherwise the delegation must
    // point to the Simple7702Account logic contract
    'eth_getCode' => delegated ? '0xef0100$_delegateNo0x' : '0x',
    // EOA nonce for the authorization
    'eth_getTransactionCount' => '0x0',
    'eth_call' => _ethCallResult(body, balance: balance),
    'eth_estimateUserOperationGas' => {
      'preVerificationGas': '0x5208',
      'verificationGasLimit': '0x186a0',
      'callGasLimit': '0x186a0',
    },
    'pimlico_getTokenQuotes' => {
      'quotes': [
        if (tokenSupported)
          {
            'token': _tokenAddress,
            'paymaster': _paymasterAddress,
            'postOpGas': '0x124f8',
            // 1e18: 1 token wei per 1 wei of gas (keeps math simple)
            'exchangeRate': '0xde0b6b3a7640000',
          },
      ],
    },
    'pimlico_getUserOperationGasPrice' => {
      'slow': {'maxFeePerGas': '0x3b9aca00', 'maxPriorityFeePerGas': '0x1'},
      'standard': {
        'maxFeePerGas': '0x3b9aca00',
        'maxPriorityFeePerGas': '0x1',
      },
      'fast': {'maxFeePerGas': '0x3b9aca00', 'maxPriorityFeePerGas': '0x1'},
    },
    'pm_getPaymasterStubData' => {
      'paymaster': _paymasterAddress,
      'paymasterData': '0xabcdef0123456789',
      'paymasterVerificationGasLimit': '0xc350',
      'paymasterPostOpGasLimit': '0x4e20',
      'isFinal': false,
    },
    'pm_getPaymasterData' => {
      'paymaster': _paymasterAddress,
      'paymasterData': '0xfedcba9876543210',
      'paymasterVerificationGasLimit': '0xc350',
      'paymasterPostOpGasLimit': '0x4e20',
    },
    _ => null,
  };
  return http.Response(
    jsonEncode({'jsonrpc': '2.0', 'id': body['id'], 'result': result}),
    200,
  );
});

/// eth_call routed by selector: balanceOf / everything else (EntryPoint
/// getNonce, ERC-20 allowance) returns zero
String _ethCallResult(Map<String, dynamic> body, {BigInt? balance}) {
  final tx = (body['params'] as List).first as Map<String, dynamic>;
  final data = (tx['data'] as String? ?? '0x').toLowerCase();
  // balanceOf(address)
  if (data.startsWith('0x70a08231')) {
    return _uint256(balance ?? BigInt.parse('1000000000000000000000000000'));
  }
  return _uint256(BigInt.zero);
}

TransactionsServiceEthereumGasFreeImpl _service({
  required http.Client httpClient,
  Future<String> Function(String masterKey)? getSigningKey,
  String pimlicoApiUri = 'http://localhost:3000/pimlico',
}) => TransactionsServiceEthereumGasFreeImpl(
  appBlockchain: AppBlockchain.ethereum,
  nodeApiUri: 'http://localhost:8545',
  pimlicoApiUri: pimlicoApiUri,
  getSigningKey: getSigningKey ?? (_) async => _testMnemonic,
  getHeaders: () => {
    'Authorization': 'test-token',
  },
  httpClient: httpClient,
);

TransferParamsGasFreeETH _params({
  BigRational? amount,
  BigRational? serviceFeeAmount,
  String? serviceFeeCollector = _collectorAddress,
  TokenWalletType tokenWalletType = TokenWalletType.child,
}) => TransferParamsGasFreeETH(
  to: _recipientAddress,
  from: _senderAddress,
  amount: amount ?? BigRational.parseDecimal('1.5'),
  chainId: 11155111,
  tokenDecimal: 6,
  tokenContractAddress: _tokenAddress,
  tokenWalletType: tokenWalletType,
  serviceFeeAmount: serviceFeeAmount ?? BigRational.parseDecimal('0.1'),
  serviceFeeCollector: serviceFeeCollector,
  tokenName: 'USDC',
);

void main() {
  group('TransactionsServiceEthereumGasFreeImpl.createTransaction', () {
    test(
      'first op (no delegation): payload carries eip7702Auth, the 0x7702 '
      'factory marker, both transfers and the paymaster approval',
      () async {
        final log = <Map<String, dynamic>>[];
        final service = _service(httpClient: _mockRpc(log: log));

        final payload = await service.createTransaction(
          params: _params(),
          masterKey: 'mk',
        );

        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        expect(decoded['jsonrpc'], equals('2.0'));
        expect(decoded['method'], equals('eth_sendUserOperation'));

        final rpcParams = decoded['params'] as List<dynamic>;
        expect(rpcParams, hasLength(2));
        expect(
          (rpcParams[1] as String).toLowerCase(),
          equals(_entryPointV08),
        );

        final userOp = rpcParams[0] as Map<String, dynamic>;
        // EIP-7702: account address == EOA of the sender
        expect(
          (userOp['sender'] as String).toLowerCase(),
          equals(_senderAddress.toLowerCase()),
        );
        // First op: the signed authorization installs the delegation
        expect(userOp['eip7702Auth'], isNotNull);
        expect(userOp['factory'], equals('0x7702'));
        // The op is signed
        expect(userOp['signature'], isNotNull);
        expect(userOp['signature'], isNot(equals('0x')));
        // Paymaster fields are in place
        expect(userOp['paymaster'], isNotNull);
        expect(userOp['paymasterData'], isNotNull);

        // The batch calldata carries the recipient transfer, the service fee
        // transfer and the injected paymaster approval
        final callData = (userOp['callData'] as String).toLowerCase();
        expect(
          callData,
          contains(_recipientAddress.substring(2).toLowerCase()),
        );
        expect(
          callData,
          contains(_collectorAddress.substring(2).toLowerCase()),
        );
        expect(
          callData,
          contains(_paymasterAddress.substring(2).toLowerCase()),
        );

        // Prepare economy: exactly one paid pm_getPaymasterData per op
        expect(
          log.where((r) => r['method'] == 'pm_getPaymasterData').length,
          equals(1),
        );
      },
    );

    test(
      'subsequent op (delegation active): no eip7702Auth in the payload, '
      'stable token type is accepted',
      () async {
        final service = _service(httpClient: _mockRpc(delegated: true));

        final payload = await service.createTransaction(
          // Stables come from the backend with the stable type - also valid
          params: _params(tokenWalletType: TokenWalletType.stable),
          masterKey: 'mk',
        );

        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final userOpJson =
            (decoded['params'] as List<dynamic>)[0] as Map<String, dynamic>;
        expect(userOpJson.containsKey('eip7702Auth'), isFalse);
        expect(userOpJson['signature'], isNot(equals('0x')));
      },
    );

    test(
      'service fee is optional: no collector transfer in calldata',
      () async {
        final service = _service(httpClient: _mockRpc());

        final payload = await service.createTransaction(
          params: _params(
            serviceFeeAmount: BigRational.zero,
            serviceFeeCollector: null,
          ),
          masterKey: 'mk',
        );

        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final userOp =
            (decoded['params'] as List<dynamic>)[0] as Map<String, dynamic>;
        final callData = (userOp['callData'] as String).toLowerCase();
        expect(
          callData,
          contains(_recipientAddress.substring(2).toLowerCase()),
        );
        expect(
          callData,
          isNot(contains(_collectorAddress.substring(2).toLowerCase())),
        );
      },
    );

    test('ASSERTS on master token type (native coin is not applicable)', () {
      expect(
        () => _params(tokenWalletType: TokenWalletType.master),
        throwsA(isA<AssertionError>()),
      );
    });

    test('THROWS wrongToken for the unknown token type', () async {
      final service = _service(httpClient: _mockRpc());

      await expectLater(
        service.createTransaction(
          params: _params(tokenWalletType: TokenWalletType.unknown),
          masterKey: 'mk',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.wrongToken,
          ),
        ),
      );
    });

    test('THROWS amountIsNotPositive for a zero amount', () async {
      final service = _service(httpClient: _mockRpc());

      await expectLater(
        service.createTransaction(
          params: _params(amount: BigRational.zero),
          masterKey: 'mk',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.amountIsNotPositive,
          ),
        ),
      );
    });

    test('THROWS invalidCommissionAmount for a negative service fee', () async {
      final service = _service(httpClient: _mockRpc());

      await expectLater(
        service.createTransaction(
          params: _params(
            serviceFeeAmount: BigRational.parseDecimal('-0.1'),
          ),
          masterKey: 'mk',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.invalidCommissionAmount,
          ),
        ),
      );
    });

    test(
      'THROWS invalidCommissionAmount for a positive service fee without '
      'a collector',
      () async {
        final service = _service(httpClient: _mockRpc());

        await expectLater(
          service.createTransaction(
            params: _params(serviceFeeCollector: null),
            masterKey: 'mk',
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.invalidCommissionAmount,
            ),
          ),
        );
      },
    );

    test(
      'THROWS invalidCommissionAmount for a garbage collector address '
      '(typed error instead of FormatException from fromHex)',
      () async {
        final service = _service(httpClient: _mockRpc());

        await expectLater(
          service.createTransaction(
            params: _params(serviceFeeCollector: 'not-an-address'),
            masterKey: 'mk',
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.invalidCommissionAmount,
            ),
          ),
        );
      },
    );

    test('THROWS unableToRetrieveMnemonic for an empty mnemonic', () async {
      final service = _service(
        httpClient: _mockRpc(),
        getSigningKey: (_) async => '',
      );

      await expectLater(
        service.createTransaction(params: _params(), masterKey: 'mk'),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.unableToRetrieveMnemonic,
          ),
        ),
      );
    });

    test(
      'THROWS tokenIsNotSupported when the paymaster has no quote',
      () async {
        final service = _service(httpClient: _mockRpc(tokenSupported: false));

        await expectLater(
          service.createTransaction(params: _params(), masterKey: 'mk'),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.tokenIsNotSupported,
            ),
          ),
        );
      },
    );

    test(
      'THROWS insufficientBalanceToPayFee when the transfers fit but the '
      'max gas cost does not',
      () async {
        // Exactly the transfers (1.5 + 0.1), nothing left for the gas
        final service = _service(
          httpClient: _mockRpc(balance: BigInt.from(1600000)),
        );

        await expectLater(
          service.createTransaction(params: _params(), masterKey: 'mk'),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.insufficientBalanceToPayFee,
            ),
          ),
        );
      },
    );

    test(
      'THROWS insufficientBalance when even the transfers do not fit',
      () async {
        // Below the transfers themselves: sending less is not the answer
        final service = _service(
          httpClient: _mockRpc(balance: BigInt.from(1000000)),
        );

        await expectLater(
          service.createTransaction(params: _params(), masterKey: 'mk'),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.insufficientBalance,
            ),
          ),
        );
      },
    );

    test('THROWS rpcError when the bundler rejects the op', () async {
      final service = _service(httpClient: _mockRpc(failEstimate: true));

      await expectLater(
        service.createTransaction(params: _params(), masterKey: 'mk'),
        throwsA(
          isA<AppBundlerRpcException>()
              .having((e) => e.code, 'code', ExceptionCode.rpcError)
              .having((e) => e.rpcCode, 'rpcCode', -32500)
              .having((e) => e.cannotChargeGas, 'cannotChargeGas', isFalse),
        ),
      );
    });
  });
  group('TransactionsServiceEthereumGasFreeImpl estimate + send flow', () {
    Future<GasfreeEstimate> estimate({
      required List<Map<String, dynamic>> log,
      bool delegated = false,
    }) =>
        _service(
          httpClient: _mockRpc(delegated: delegated, log: log),
        ).estimateGasFree(
          chainId: 11155111,
          senderAddress: _senderAddress,
          recipientAddress: _recipientAddress,
          tokenContractAddress: _tokenAddress,
          tokenDecimal: 6,
          serviceFeeCollector: _collectorAddress,
        );

    test(
      'estimateGasFree: single paid round (quote + prices + stub + '
      'gas estimate), correct math',
      () async {
        final log = <Map<String, dynamic>>[];
        final result = await estimate(log: log);

        int count(String method) =>
            log.where((r) => r['method'] == method).length;
        expect(count('pimlico_getTokenQuotes'), 1);
        expect(count('pimlico_getUserOperationGasPrice'), 1);
        expect(count('pm_getPaymasterStubData'), 1);
        expect(count('eth_estimateUserOperationGas'), 1);
        // No final paid paymaster data during estimation
        expect(count('pm_getPaymasterData'), 0);

        expect(result.needsDelegation, isTrue);
        // (21000 + 100000 + 100000 + 50000 + 20000 + 75000 postOpGas)
        // x 1 gwei x rate 1e18 / 1e18 = 3.66e14 raw; / 1e6 decimals
        expect(
          result.expectedFeeInToken,
          BigRational.parseDecimal('366000000'),
        );
        expect(
          result.maxCostInToken,
          BigInt.from(366000) * BigInt.from(10).pow(9),
        );
        expect(result.includesServiceFee, isTrue);
        expect(
          result.paymasterAddress.toLowerCase(),
          _paymasterAddress.toLowerCase(),
        );
      },
    );

    test(
      'createTransactionFromEstimate: exactly ONE paid call '
      '(pm_getPaymasterData), first-op payload carries eip7702Auth',
      () async {
        final estimateLog = <Map<String, dynamic>>[];
        final cached = await estimate(log: estimateLog);

        final sendLog = <Map<String, dynamic>>[];
        final payload =
            await _service(
              httpClient: _mockRpc(log: sendLog),
            ).createTransactionFromEstimate(
              params: _params(),
              estimate: cached,
              masterKey: 'mk',
            );

        int count(String method) =>
            sendLog.where((r) => r['method'] == method).length;
        // The only paid call
        expect(count('pm_getPaymasterData'), 1);
        expect(count('pm_getPaymasterStubData'), 0);
        expect(count('eth_estimateUserOperationGas'), 0);
        expect(count('pimlico_getTokenQuotes'), 0);
        expect(count('pimlico_getUserOperationGasPrice'), 0);

        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        expect(decoded['method'], equals('eth_sendUserOperation'));
        final userOp =
            (decoded['params'] as List<dynamic>)[0] as Map<String, dynamic>;
        expect(userOp['eip7702Auth'], isNotNull);
        expect(userOp['factory'], equals('0x7702'));
        expect(userOp['signature'], isNot(equals('0x')));
        // Gas limits are taken from the estimate
        expect(userOp['callGasLimit'], equals('0x186a0'));
        // Calldata: both transfers + approve for maxCostInToken
        final callData = (userOp['callData'] as String).toLowerCase();
        expect(
          callData,
          contains(_recipientAddress.substring(2).toLowerCase()),
        );
        expect(
          callData,
          contains(_collectorAddress.substring(2).toLowerCase()),
        );
        expect(
          callData,
          contains(_paymasterAddress.substring(2).toLowerCase()),
        );
      },
    );

    test(
      'createTransactionFromEstimate: subsequent op - no eip7702Auth',
      () async {
        final cached = await estimate(
          log: <Map<String, dynamic>>[],
          delegated: true,
        );
        expect(cached.needsDelegation, isFalse);

        final payload =
            await _service(
              httpClient: _mockRpc(delegated: true),
            ).createTransactionFromEstimate(
              params: _params(),
              estimate: cached,
              masterKey: 'mk',
            );

        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final userOp =
            (decoded['params'] as List<dynamic>)[0] as Map<String, dynamic>;
        expect(userOp.containsKey('eip7702Auth'), isFalse);
      },
    );

    test(
      'createTransactionFromEstimate: THROWS when the estimate does not '
      'match the transfer params',
      () async {
        final cached = await estimate(log: <Map<String, dynamic>>[]);

        await expectLater(
          _service(httpClient: _mockRpc()).createTransactionFromEstimate(
            // The estimate included a service fee, the transfer does not
            params: _params(
              serviceFeeAmount: BigRational.zero,
              serviceFeeCollector: null,
            ),
            estimate: cached,
            masterKey: 'mk',
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.unableToCreateTransaction,
            ),
          ),
        );
      },
    );

    test(
      'estimateGasFree: an empty collector string is equivalent to '
      'no service fee',
      () async {
        final result =
            await _service(
              httpClient: _mockRpc(),
            ).estimateGasFree(
              chainId: 11155111,
              senderAddress: _senderAddress,
              recipientAddress: _recipientAddress,
              tokenContractAddress: _tokenAddress,
              tokenDecimal: 6,
              serviceFeeCollector: '',
            );
        expect(result.includesServiceFee, isFalse);
      },
    );

    test(
      'estimateGasFree: THROWS tokenIsNotSupported without a quote',
      () async {
        await expectLater(
          _service(
            httpClient: _mockRpc(tokenSupported: false),
          ).estimateGasFree(
            chainId: 11155111,
            senderAddress: _senderAddress,
            recipientAddress: _recipientAddress,
            tokenContractAddress: _tokenAddress,
            tokenDecimal: 6,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              ExceptionCode.tokenIsNotSupported,
            ),
          ),
        );
      },
    );

    test(
      'estimateGasFree: THROWS insufficientBalanceToPayFee when postOp '
      'cannot charge the gas fee (AA50)',
      () async {
        // The paymaster pulls the fee in postOp: a balance that does not
        // cover the gas reverts the simulation. Deterministic for the
        // current balance, the caller must not retry it
        await expectLater(
          _service(
            httpClient: _mockRpc(
              failEstimate: true,
              estimateErrorMessage:
                  'UserOperation reverted during simulation with reason: '
                  'AA50 postOp reverted 0x7939f424',
            ),
          ).estimateGasFree(
            chainId: 11155111,
            senderAddress: _senderAddress,
            recipientAddress: _recipientAddress,
            tokenContractAddress: _tokenAddress,
            tokenDecimal: 6,
          ),
          throwsA(
            isA<AppBundlerRpcException>()
                .having(
                  (e) => e.code,
                  'code',
                  ExceptionCode.insufficientBalanceToPayFee,
                )
                .having((e) => e.aaCode, 'aaCode', 'AA50')
                .having((e) => e.cannotChargeGas, 'cannotChargeGas', isTrue),
          ),
        );
      },
    );

    test(
      'estimateGasFree: THROWS insufficientBalanceToPayFee on a bare '
      'TransferFromFailed selector, without an AA code',
      () async {
        await expectLater(
          _service(
            httpClient: _mockRpc(
              failEstimate: true,
              estimateErrorMessage: 'execution reverted: 0x7939f424',
            ),
          ).estimateGasFree(
            chainId: 11155111,
            senderAddress: _senderAddress,
            recipientAddress: _recipientAddress,
            tokenContractAddress: _tokenAddress,
            tokenDecimal: 6,
          ),
          throwsA(
            isA<AppBundlerRpcException>()
                .having(
                  (e) => e.code,
                  'code',
                  ExceptionCode.insufficientBalanceToPayFee,
                )
                // Бандлер не назвал AA-код, распознали по селектору
                .having((e) => e.aaCode, 'aaCode', isNull),
          ),
        );
      },
    );

    test(
      'estimateGasFree: any other bundler error stays rpcError (retryable)',
      () async {
        await expectLater(
          _service(
            httpClient: _mockRpc(
              failEstimate: true,
              estimateErrorMessage: 'AA33 paymaster reverted',
            ),
          ).estimateGasFree(
            chainId: 11155111,
            senderAddress: _senderAddress,
            recipientAddress: _recipientAddress,
            tokenContractAddress: _tokenAddress,
            tokenDecimal: 6,
          ),
          throwsA(
            isA<AppBundlerRpcException>()
                .having((e) => e.code, 'code', ExceptionCode.rpcError)
                .having((e) => e.aaCode, 'aaCode', 'AA33'),
          ),
        );
      },
    );
  });

  group('TransactionsServiceEthereumGasFreeImpl helpers', () {
    test('pimlicoUrlForChain appends the chain id, trailing slash handled', () {
      final service = _service(httpClient: _mockRpc());
      expect(
        service.pimlicoUrlForChain(11155111),
        equals('http://localhost:3000/pimlico/11155111'),
      );

      final serviceSlash = _service(
        httpClient: _mockRpc(),
        pimlicoApiUri: 'http://localhost:3000/pimlico/',
      );
      expect(
        serviceSlash.pimlicoUrlForChain(1),
        equals('http://localhost:3000/pimlico/1'),
      );

      // Placeholder for a direct Pimlico URL
      final serviceTemplate = _service(
        httpClient: _mockRpc(),
        pimlicoApiUri: 'https://api.pimlico.io/v2/{chainId}/rpc?apikey=x',
      );
      expect(
        serviceTemplate.pimlicoUrlForChain(11155111),
        equals('https://api.pimlico.io/v2/11155111/rpc?apikey=x'),
      );

      // Query parameters (apikey) are preserved when appending the segment
      final serviceQuery = _service(
        httpClient: _mockRpc(),
        pimlicoApiUri: 'https://api.pimlico.io/v2?apikey=x',
      );
      expect(
        serviceQuery.pimlicoUrlForChain(1),
        equals('https://api.pimlico.io/v2/1?apikey=x'),
      );

      // Full single-chain URL (chain segment already in the path) - as is
      final serviceFull = _service(
        httpClient: _mockRpc(),
        pimlicoApiUri: 'https://api.pimlico.io/v2/11155111/rpc?apikey=x',
      );
      expect(
        serviceFull.pimlicoUrlForChain(11155111),
        equals('https://api.pimlico.io/v2/11155111/rpc?apikey=x'),
      );
    });

    test('initializeWalletAndGetInfo derives the EOA address', () async {
      final service = _service(httpClient: _mockRpc());
      final info = await service.initializeWalletAndGetInfo(masterKey: 'mk');
      expect(info.address, equals(_senderAddress));
      expect(info.pkAsBytes, isNotEmpty);
    });
  });
}
