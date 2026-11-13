import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// BTC Node Interface
///
/// The methods throw on a failure, the service passes the exception on to its
/// caller as is
abstract interface class BTCNodeRepo {
  /// Get utxos for address = Api v1
  Future<List<AppUtxo>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  });

  /// Get utxos for address = Api v2
  Future<List<AppUtxo>> fetchUtxosV2({
    required String address,
    bool? confirmed,
  });

  /// Transaction information
  Future<TransactionBtcNode> fetchTransaction({
    required String txId,
  });
}
