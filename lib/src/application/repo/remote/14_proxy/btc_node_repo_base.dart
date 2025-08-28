import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// BTC Node Interface
abstract interface class BTCNodeRepo {
  /// Get utxos for address = Api v1
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  });

  /// Get utxos for address = Api v2
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV2({
    required String address,
    bool? confirmed,
  });

  /// Transaction information
  Future<Either<AppExceptionWithCode, TransactionBtcNode>> fetchTransaction({
    required String txId,
  });
}
