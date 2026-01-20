import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:dio/dio.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../api/btc_explorer_service.dart';
import '../api/client.cg.dart';

/// BTCNodeRepoImpl
final class BTCNodeRepoImpl implements BTCNodeRepo {
  BTCNodeRepoImpl({
    required this.apiKey,
    required this.isTestnet,
    required this.baseUrl,
  }) : _api = ApiProvider.fromMempool(
         BitcoinNetwork.signet,
         BitcoinApiService(),
       ),
       _client = BtcNodeClient(
         Dio(BaseOptions(baseUrl: baseUrl)),
       );

  final ApiProvider _api;

  final BtcNodeClient _client;

  final String apiKey;

  final bool isTestnet;

  final String baseUrl;

  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  }) async {
    try {
      final response = await _client.fetchUtxosV1(
        address: address,
        blockBook: isTestnet ? 'btc_blockbook_signet' : 'btc_blockbook',
        confirmed: confirmed,
        apiToken: apiKey,
      );
      return Right(response.map((e) => e.toDomainOrThrow()).toList());
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV2({
    required String address,
    bool? confirmed,
  }) async {
    try {
      final response = await _client.fetchUtxosV2(
        address: address,
        blockBook: isTestnet ? 'btc_blockbook_signet' : 'btc_blockbook',
        confirmed: confirmed,
        apiToken: apiKey,
      );
      return Right(response.map((e) => e.toDomainOrThrow()).toList());
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppExceptionWithCode, TransactionBtcNode>> fetchTransaction({
    required String txId,
  }) async {
    try {
      final response = await _client.fetchTransaction(
        txId: txId,
        blockBook: isTestnet ? 'btc_blockbook_signet' : 'btc_blockbook',
        apiToken: apiKey,
      );
      return Right(response.toDomainOrThrow());
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
    }
  }

  /// For example purposes only.
  ///
  /// Not a part of core base interface [BTCNodeRepo]
  Future<TransactionInfoData> postTransaction({
    required String tx,
  }) async {
    final service = BitcoinApiService();
    final api = ApiProvider.fromMempool(
      isTestnet ? BitcoinNetwork.signet : BitcoinNetwork.mainnet,
      service,
    );
    final txId = await api.sendRawTransaction(tx);
    return TransactionInfoData(
      txId: txId,
      linkToBlockchain: 'https://mempool.space/signet/tx/$txId',
    );
  }

  /// For example purposes only.
  ///
  /// Not a part of core base interface [BTCNodeRepo]
  Future<Either<AppExceptionWithCode, EstimateFeeModel>> getEstimateFee({
    required double amount,
    required AppBlockchain appBlockchain,
    String? recipientAddress,
    String? tokenContractAddress,
    required TokenWalletType tokenWalletType,
  }) async {
    try {
      // By now (28/08/25) fees are parsing in wrong way in [bitcoin_base] 6.8.0
      final fees = await _api.getNetworkFeeRate();
      return Right(
        EstimateFeeModel(
          fee: fees.medium.toDouble(),
          energy: 0,
          fees: Fees(
            fastestFee: fees.high.toInt(),
            halfHourFee: fees.medium.toInt(),
            economyFee: fees.economyFee?.toInt() ?? fees.medium.toInt(),
          ),
          txDustThreshold: BigInt.from(350),
        ),
      );
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
    }
  }
}
