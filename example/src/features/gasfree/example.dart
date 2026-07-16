// Live-check example for the gasfree flow "estimate + send" (task 1333).
//
// Verifies the two key points:
// 1. estimateGasFree works WITHOUT the private key (for the first operation
//    a dummy authorization goes into the estimation);
// 2. createTransactionFromEstimate built from a cached estimate performs
//    exactly ONE paid call (pm_getPaymasterData) - the call counter is
//    printed per stage.
//
// USAGE (from the tron_energy_wallet_core folder):
//   GASFREE_RPC_URL='https://ethereum-sepolia-rpc.publicnode.com' \
//   GASFREE_PIMLICO_URL='https://api.pimlico.io/v2/{chainId}/rpc?apikey=KEY' \
//   GASFREE_MNEMONIC='12 words of a TEST wallet' \
//   GASFREE_SEND=false \
//   dart run example/src/features/gasfree/example.dart
//
// GASFREE_SEND=true - actually submit the UserOperation (the example relays
// the payload to Pimlico emulating the backend and polls the receipt).
//
// Secrets come from environment variables ONLY - never hardcode them here.

// Console example - print output is fine
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

// Sepolia
const _chainId = 11155111;

// Sepolia USDC (6 decimals) - supported by the Pimlico ERC-20 paymaster
const _tokenAddress = '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238';
const _tokenDecimal = 6;

// Transfer recipient
const _recipientAddress = '0x077B122c047a58174f1e8B011C8A6F768C0AC190';

// Service fee collector (null - the service fee stream is disabled).
// Nullability is deliberate - it is a toggle
// ignore: unnecessary_nullable_for_final_variable_declarations
const String? _serviceFeeCollector =
    '0x13606ab8031652FcB18E28676A1a6458806Ffd73';

// Amounts in token units
final _amount = BigRational.parseDecimal('0.1');
final _serviceFee = BigRational.parseDecimal('0.01');

/// JSON-RPC call counter by method (to control the paid-call economy)
class _CountingHttpClient extends http.BaseClient {
  _CountingHttpClient(this._inner);

  final http.Client _inner;

  /// method -> call count
  final Map<String, int> calls = {};

  void reset() => calls.clear();

  String get summary => calls.isEmpty
      ? '(no calls)'
      : (calls.entries.map((e) => '  ${e.key}: ${e.value}').join('\n'));

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request is http.Request && request.body.isNotEmpty) {
      try {
        final method =
            (jsonDecode(request.body) as Map<String, dynamic>)['method'];
        calls['$method'] = (calls['$method'] ?? 0) + 1;
      } on FormatException {
        // not JSON-RPC - do not count
      }
    }
    return _inner.send(request);
  }
}

/// Same rule as in the service: placeholder / chain already in the path /
/// append the segment preserving the query
String _chainUrl(String base, int chainId) {
  if (base.contains('{chainId}')) {
    return base.replaceAll('{chainId}', '$chainId');
  }
  final uri = Uri.parse(base);
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.contains('$chainId')) return base;
  return uri.replace(pathSegments: [...segments, '$chainId']).toString();
}

/// Do not print the apikey to the console
String _masked(String url) =>
    url.replaceAll(RegExp('apikey=[^&]+'), 'apikey=***');

Future<void> main() async {
  final rpcUrl = Platform.environment['GASFREE_RPC_URL'] ?? '';
  final pimlicoUrl = Platform.environment['GASFREE_PIMLICO_URL'] ?? '';
  final mnemonic = Platform.environment['GASFREE_MNEMONIC'] ?? '';
  final send = Platform.environment['GASFREE_SEND'] == 'true';

  if (rpcUrl.isEmpty || pimlicoUrl.isEmpty || mnemonic.isEmpty) {
    print('Required env variables: GASFREE_RPC_URL, GASFREE_PIMLICO_URL '
        '(with the {chainId} placeholder or a full single-chain URL), '
        'GASFREE_MNEMONIC');
    exit(1);
  }

  final counter = _CountingHttpClient(http.Client());

  final service = TransactionsServiceEthereumGasfreeImpl(
    appBlockchain: AppBlockchain.ethereum,
    nodeApiUri: rpcUrl,
    pimlicoApiUri: pimlicoUrl,
    getSigningKey: (_) async => mnemonic,
    httpClient: counter,
  );

  final info = await service.initializeWalletAndGetInfo(masterKey: '');
  final sender = info.address;
  print('=' * 60);
  print('Gasfree: key-less estimation + single-paid-call send');
  print('=' * 60);
  print('Sender:    $sender');
  print('Recipient: $_recipientAddress');
  print('Pimlico chain URL: ${_masked(_chainUrl(pimlicoUrl, _chainId))}');
  print(
    'Amount: $_amount USDC, service fee: '
    '${_serviceFeeCollector != null ? _serviceFee : 'disabled'}',
  );

  // ==============================================================
  // 1. Estimation (NO key): one paid round
  // ==============================================================
  counter.reset();
  print('\n--- 1. estimateGasFree (no key) ---');
  final estimate = await service.estimateGasFree(
    chainId: _chainId,
    senderAddress: sender,
    recipientAddress: _recipientAddress,
    tokenContractAddress: _tokenAddress,
    tokenDecimal: _tokenDecimal,
    serviceFeeCollector: _serviceFeeCollector,
  );
  print('First operation (delegation): ${estimate.needsDelegation}');
  print(
    'Expected fee: ${estimate.expectedFeeInToken.toDecimal(
      digits: _tokenDecimal,
    )} USDC',
  );
  print(
    'Maximum (paymaster approve): ${BigRational(
          estimate.maxCostInToken,
        ) / BigRational(BigInt.from(10).pow(_tokenDecimal))} USDC',
  );
  print('Calls during estimation:\n${counter.summary}');

  // ==============================================================
  // 2. Transaction assembly from the estimate: exactly one paid call
  // ==============================================================
  counter.reset();
  print('\n--- 2. createTransactionFromEstimate ---');
  final payload = await service.createTransactionFromEstimate(
    params: TransferParamsGasfreeETH(
      to: _recipientAddress,
      from: sender,
      amount: _amount,
      chainId: _chainId,
      tokenDecimal: _tokenDecimal,
      tokenContractAddress: _tokenAddress,
      tokenWalletType: TokenWalletType.child,
      tokenName: 'USDC',
      serviceFeeAmount: _serviceFeeCollector != null ? _serviceFee : null,
      serviceFeeCollector: _serviceFeeCollector,
    ),
    estimate: estimate,
    masterKey: '',
  );
  print(
    'Calls during assembly (pm_getPaymasterData plus free eth_* only '
    'expected):\n${counter.summary}',
  );
  final userOpJson =
      ((jsonDecode(payload) as Map<String, dynamic>)['params']
              as List<dynamic>)[0]
          as Map<String, dynamic>;
  print('eip7702Auth in payload: ${userOpJson.containsKey('eip7702Auth')}');
  print('factory: ${userOpJson['factory']}');

  if (!send) {
    print('\nGASFREE_SEND != true - submission skipped. Payload is ready:');
    print(payload);
    exit(0);
  }

  // ==============================================================
  // 3. Submission: the example emulates the backend - relays the payload
  //    verbatim
  // ==============================================================
  print('\n--- 3. Submission (backend emulation) ---');
  final chainUrl = Uri.parse(_chainUrl(pimlicoUrl, _chainId));
  final sendResponse = await http.post(
    chainUrl,
    headers: {'Content-Type': 'application/json'},
    body: payload,
  );
  final sendJson = jsonDecode(sendResponse.body) as Map<String, dynamic>;
  if (sendJson['error'] != null) {
    print('Bundler error: ${sendJson['error']}');
    exit(1);
  }
  final userOpHash = sendJson['result'] as String;
  print('userOpHash: $userOpHash');

  print('Waiting for the receipt...');
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(const Duration(seconds: 3));
    final receiptResponse = await http.post(
      chainUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'eth_getUserOperationReceipt',
        'params': [userOpHash],
      }),
    );
    final receiptJson =
        jsonDecode(receiptResponse.body) as Map<String, dynamic>;
    final result = receiptJson['result'];
    if (result == null) continue;
    final receipt = result as Map<String, dynamic>;
    final txHash =
        (receipt['receipt'] as Map<String, dynamic>)['transactionHash'];
    print('SUCCESS: success=${receipt['success']}, '
        'actualGasCost=${receipt['actualGasCost']}');
    print('txHash: $txHash');
    print('https://sepolia.etherscan.io/tx/$txHash');
    exit(0);
  }
  print('No receipt within 90s - check by userOpHash manually');
  exit(1);
}
