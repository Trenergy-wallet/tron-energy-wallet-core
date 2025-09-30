import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// ETH Node Interface
abstract interface class ETHNodeRepo {
  /// sendRawTransaction
  Future<Either<AppExceptionWithCode, String>> sendRawTransaction({
    required String rawTransaction,
    int id = 1,
  });
}
