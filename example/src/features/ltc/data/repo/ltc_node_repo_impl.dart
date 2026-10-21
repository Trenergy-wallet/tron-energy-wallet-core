import 'dart:convert';

import 'package:blockchain_utils/blockchain_utils.dart'
    show BigRational, BytesUtils;
import 'package:http/http.dart' as http;
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'ltc_example_node_repo.dart';

/// [BTCNodeRepo] over the mempool compatible API of litecoinspace.org
///
/// The wallet takes the same data from the Blockbook proxy of the backend
/// (see `LTCBlockbookRepoImpl`). Here the mempool format is mapped to the
/// Blockbook based domain models: it serves testnet and needs no API key
final class LTCNodeRepoImpl implements LTCExampleNodeRepo {
  LTCNodeRepoImpl({required this.isTestnet, http.Client? client})
    : _client = client ?? http.Client();

  final bool isTestnet;

  final http.Client _client;

  String get _baseUrl => isTestnet
      ? 'https://litecoinspace.org/testnet/api'
      : 'https://litecoinspace.org/api';

  /// Mempool API has no node cache, so v1 and v2 return the same data
  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  }) => _run(() => _fetchUtxos(address: address, confirmed: confirmed));

  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV2({
    required String address,
    bool? confirmed,
  }) => _run(() => _fetchUtxos(address: address, confirmed: confirmed));

  @override
  Future<Either<AppExceptionWithCode, TransactionBtcNode>> fetchTransaction({
    required String txId,
  }) => _run(() async {
    final [txJson, tipJson] = await Future.wait([
      _get('/tx/$txId'),
      _get('/blocks/tip/height'),
    ]);
    final tx = txJson as Map<String, dynamic>;
    final tip = tipJson as int;
    final status = tx['status'] as Map<String, dynamic>;
    final vin = (tx['vin'] as List).cast<Map<String, dynamic>>();
    final vout = (tx['vout'] as List).cast<Map<String, dynamic>>();
    return TransactionBtcNode(
      txId: tx['txid'] as String,
      vin: [for (final (n, e) in vin.indexed) _toVin(n, e)],
      vout: [for (final (n, e) in vout.indexed) _toVout(n, e)],
      blockHeight: status['block_height'] as int? ?? CoreConsts.invalidIntValue,
      confirmations: _confirmations(status, tip),
      // BIP-125: an input with sequence below 0xfffffffe signals RBF
      rbf: vin.any((e) => (e['sequence'] as int) < 0xfffffffe),
      fees: tx['fee'] as int?,
      size: tx['size'] as int,
      vSize: ((tx['weight'] as int) / 4).ceil(),
    );
  });

  @override
  Future<Either<AppExceptionWithCode, EstimateFeeModel>> getEstimateFee({
    required double amount,
    required AppBlockchain appBlockchain,
    required TokenWalletType tokenWalletType,
    String? recipientAddress,
    String? tokenContractAddress,
  }) => _run(() async {
    final fees = await _get('/v1/fees/recommended') as Map<String, dynamic>;
    final halfHourFee = fees['halfHourFee'] as int;
    return EstimateFeeModel(
      fee: BigRational.from(halfHourFee),
      energy: 0,
      fees: Fees(
        fastestFee: fees['fastestFee'] as int,
        halfHourFee: halfHourFee,
        economyFee: fees['economyFee'] as int,
      ),
      // Conservative value for the example
      txDustThreshold: BigInt.from(1000),
    );
  });

  @override
  Future<String> broadcast(String rawTx) async {
    final response = await _client
        .post(Uri.parse('$_baseUrl/tx'), body: rawTx)
        .timeout(CoreConsts.defaultRequestTimeout);
    if (response.statusCode != 200) {
      throw AppBackendException(
        message: 'broadcast: ${response.statusCode} ${response.body}',
      );
    }
    return response.body;
  }

  Future<List<AppUtxo>> _fetchUtxos({
    required String address,
    bool? confirmed,
  }) async {
    final [utxosJson, tipJson] = await Future.wait([
      _get('/address/$address/utxo'),
      _get('/blocks/tip/height'),
    ]);
    final utxos = (utxosJson as List).cast<Map<String, dynamic>>();
    final tip = tipJson as int;
    return [
      for (final e in utxos)
        if (_toUtxo(e, tip) case final utxo
            when confirmed == null || (utxo.confirmations > 0) == confirmed)
          utxo,
    ];
  }

  AppUtxo _toUtxo(Map<String, dynamic> e, int tip) {
    final status = e['status'] as Map<String, dynamic>;
    return AppUtxo(
      txid: e['txid'] as String,
      vout: e['vout'] as int,
      value: BigInt.from(e['value'] as int),
      height: status['block_height'] as int? ?? CoreConsts.invalidIntValue,
      confirmations: _confirmations(status, tip),
    );
  }

  Vin _toVin(int n, Map<String, dynamic> e) {
    // No prevout for a coinbase input
    final prevout = e['prevout'] as Map<String, dynamic>?;
    final address = prevout?['scriptpubkey_address'] as String?;
    return Vin(
      txId: e['txid'] as String,
      sequence: e['sequence'] as int,
      n: n,
      addresses: [?address],
      isAddress: address != null,
      valueInSatoshi: prevout?['value'] as int? ?? 0,
    );
  }

  Vout _toVout(int n, Map<String, dynamic> e) {
    final hex = e['scriptpubkey'] as String;
    final address = e['scriptpubkey_address'] as String?;
    final opReturn = address == null ? _opReturnText(hex) : null;
    return Vout(
      valueInSatoshi: e['value'] as int,
      n: n,
      hex: hex,
      // Blockbook format: the core reads the message from `OP_RETURN (text)`
      addresses: [?address, if (opReturn != null) 'OP_RETURN ($opReturn)'],
      isAddress: address != null,
    );
  }

  /// Text of a single push OP_RETURN script, null for any other script
  String? _opReturnText(String scriptHex) {
    final bytes = BytesUtils.fromHexString(scriptHex);
    if (bytes.length < 2 || bytes[0] != 0x6a) return null;
    // Direct push (up to 75 bytes) or OP_PUSHDATA1 (76..80 bytes)
    final dataStart = bytes[1] == 0x4c ? 3 : 2;
    if (bytes.length < dataStart) return null;
    return utf8.decode(bytes.sublist(dataStart), allowMalformed: true);
  }

  int _confirmations(Map<String, dynamic> status, int tip) {
    final height = status['block_height'] as int?;
    return status['confirmed'] == true && height != null ? tip - height + 1 : 0;
  }

  Future<dynamic> _get(String path) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl$path'))
        .timeout(CoreConsts.defaultRequestTimeout);
    if (response.statusCode != 200) {
      throw AppBackendException(
        message: '$path: ${response.statusCode} ${response.body}',
      );
    }
    return jsonDecode(response.body);
  }

  Future<Either<AppExceptionWithCode, T>> _run<T>(
    Future<T> Function() request,
  ) async {
    try {
      return Right(await request());
    } on AppExceptionWithCode catch (e) {
      return Left(e);
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
      // An unexpected response shape fails the casts: return it as Left
      // ignore: avoid_catching_errors
    } on TypeError catch (e) {
      return Left(AppBackendException(message: 'Unexpected response: $e'));
    }
  }
}
