import 'dart:math';

import 'package:blockchain_utils/blockchain_utils.dart' show BigRational;
import 'package:dio/dio.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'ltc_example_node_repo.dart';

/// [BTCNodeRepo] over a Litecoin Blockbook node
///
/// The same Blockbook API and DTOs as the backend proxy of the wallet
final class LTCBlockbookRepoImpl implements LTCExampleNodeRepo {
  /// [baseUrl] is the Blockbook root, the one `/api/v2/...` is appended to
  LTCBlockbookRepoImpl({
    required String baseUrl,
    Map<String, String> headers = const {},
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           headers: headers,
           connectTimeout: CoreConsts.defaultRequestTimeout,
           receiveTimeout: CoreConsts.defaultRequestTimeout,
         ),
       );

  /// NOWNodes, mainnet and testnet, the key goes in the `api-key` header
  LTCBlockbookRepoImpl.nowNodes({
    required String apiKey,
    required bool isTestnet,
  }) : this(
         baseUrl: isTestnet
             ? 'https://ltcbook-testnet.nownodes.io'
             : 'https://ltcbook.nownodes.io',
         headers: {'api-key': apiKey},
       );

  /// GetBlock shared node, mainnet only, the access token is a part of the url
  ///
  /// https://docs.getblock.io/api-reference/litecoin/litecoin-blockbook-rest-api
  LTCBlockbookRepoImpl.getBlock({required String accessToken})
    : this(baseUrl: 'https://shared.eu-central-1.getblock.io/$accessToken');

  final Dio _dio;

  /// Confirmation targets in blocks (2.5 min each) for the fee levels
  static const _fastestBlocks = 1;
  static const _halfHourBlocks = 12;
  static const _economyBlocks = 48;

  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  }) => _run(() async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/utxo/$address',
      queryParameters: {'confirmed': ?confirmed},
    );
    return [
      for (final e in response.data!)
        AppUtxoDtoV1.fromJson(e as Map<String, dynamic>).toDomainOrThrow(),
    ];
  });

  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV2({
    required String address,
    bool? confirmed,
  }) => _run(() async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v2/utxo/$address',
      queryParameters: {'confirmed': ?confirmed},
    );
    return [
      for (final e in response.data!)
        AppUtxoDtoV2.fromJson(e as Map<String, dynamic>).toDomainOrThrow(),
    ];
  });

  @override
  Future<Either<AppExceptionWithCode, TransactionBtcNode>> fetchTransaction({
    required String txId,
  }) => _run(() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v2/tx/$txId');
    return TransactionBtcNodeDto.fromJson(response.data!).toDomainOrThrow();
  });

  @override
  Future<Either<AppExceptionWithCode, EstimateFeeModel>> getEstimateFee({
    required double amount,
    required AppBlockchain appBlockchain,
    required TokenWalletType tokenWalletType,
    String? recipientAddress,
    String? tokenContractAddress,
  }) => _run(() async {
    final [fastest, halfHour, economy] = await Future.wait([
      _feeRate(_fastestBlocks),
      _feeRate(_halfHourBlocks),
      _feeRate(_economyBlocks),
    ]);
    return EstimateFeeModel(
      fee: BigRational.from(halfHour),
      energy: 0,
      fees: Fees(
        fastestFee: fastest,
        halfHourFee: halfHour,
        economyFee: economy,
      ),
      // Conservative value for the example
      txDustThreshold: BigInt.from(1000),
    );
  });

  @override
  Future<String> broadcast(String rawTx) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v2/sendtx/',
        data: rawTx,
        options: Options(contentType: 'text/plain'),
      );
      return response.data!['result'] as String;
    } on DioException catch (e) {
      throw AppBackendException(message: 'broadcast: ${_describe(e)}');
    }
  }

  /// Blockbook returns LTC per kB, the core works in sat/vB
  Future<int> _feeRate(int blocks) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v2/estimatefee/$blocks',
    );
    final perKb = BigRational.parseDecimal(response.data!['result'] as String);
    // 1 LTC = 10^8 litoshi, 1 kB = 1000 vB
    final perVb = perKb * BigRational.from(100000);
    // A negative result means the node has no estimate
    return max(perVb.ceil().toBigInt().toInt(), 1);
  }

  /// Blockbook puts the reason into `{"error": "..."}`, a node provider may
  /// answer with plain text (`Unknown API_key`)
  String _describe(DioException e) {
    final error = switch (e.response?.data) {
      {'error': final Object error} => error,
      final String text when text.isNotEmpty => text,
      _ => e.message,
    };
    return '${e.response?.statusCode} $error';
  }

  Future<Either<AppExceptionWithCode, T>> _run<T>(
    Future<T> Function() request,
  ) async {
    try {
      return Right(await request());
    } on DioException catch (e) {
      return Left(AppBackendException(message: _describe(e)));
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
      // An unexpected response shape fails the casts: return it as Left
      // ignore: avoid_catching_errors
    } on TypeError catch (e) {
      return Left(AppBackendException(message: 'Unexpected response: $e'));
    }
  }
}
