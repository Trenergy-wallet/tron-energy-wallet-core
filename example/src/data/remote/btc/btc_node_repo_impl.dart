import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:dio/dio.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../../../../example.dart' show btcApiKey;
import '../../../core/network/bitcoin_api_service/btc_explorer_service.dart';

const _isTestNet = true;

/// BTCNodeRepoImpl
final class BTCNodeRepoImpl implements BTCNodeRepo {
  /// Singleton instance of BTCNodeRepoImpl
  factory BTCNodeRepoImpl() => _singleton;

  BTCNodeRepoImpl._internal()
    : _api = ApiProvider.fromMempool(
        BitcoinNetwork.signet,
        BitcoinApiService(),
      ),
      _client = BtcNodeClient(
        Dio(BaseOptions(baseUrl: 'https://rpc.ankr.com/')),
      );

  static final BTCNodeRepoImpl _singleton = BTCNodeRepoImpl._internal();

  final ApiProvider _api;

  final BtcNodeClient _client;

  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  }) async {
    try {
      final response = await _client.fetchUtxosV1(
        address: address,
        blockBook: _isTestNet ? 'btc_blockbook_signet' : 'btc_blockbook',
        confirmed: confirmed,
        apiToken: btcApiKey,
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
        blockBook: _isTestNet ? 'btc_blockbook_signet' : 'btc_blockbook',
        confirmed: confirmed,
        apiToken: btcApiKey,
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
        blockBook: _isTestNet ? 'btc_blockbook_signet' : 'btc_blockbook',
        apiToken: btcApiKey,
      );
      return Right(response.toDomainOrThrow());
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
    }
  }

  /// For example purposes only.
  ///
  /// Not a part of core base interface [BTCNodeRepo]
  Future<Either<AppExceptionWithCode, TransactionInfoData>> postTransaction({
    required AppBlockchain appBlockchain,
    required String tx,
    String? txFee,
  }) async {
    try {
      final service = BitcoinApiService();
      final api = ApiProvider.fromMempool(
        _isTestNet ? BitcoinNetwork.signet : BitcoinNetwork.mainnet,
        service,
      );
      final txId = await api.sendRawTransaction(tx);
      return Right(
        TransactionInfoData(
          txId: txId,
          linkToBlockchain: 'https://mempool.space/signet/tx/$txId',
        ),
      );
    } on Exception catch (e) {
      return Left(AppBackendException(message: e.toString()));
    }
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
