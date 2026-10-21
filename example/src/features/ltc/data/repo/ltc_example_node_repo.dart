import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Node repo of the Litecoin example
///
/// [getEstimateFee] and [broadcast] are not a part of core base interface
/// [BTCNodeRepo]: the wallet gets the fee rates and the dust threshold from
/// the backend (2.4) and broadcasts through it (6.2)
abstract interface class LTCExampleNodeRepo implements BTCNodeRepo {
  /// Fee rates in sat/vB
  Future<Either<AppExceptionWithCode, EstimateFeeModel>> getEstimateFee({
    required double amount,
    required AppBlockchain appBlockchain,
    required TokenWalletType tokenWalletType,
    String? recipientAddress,
    String? tokenContractAddress,
  });

  /// Sends a signed transaction, returns its id
  Future<String> broadcast(String rawTx);
}
