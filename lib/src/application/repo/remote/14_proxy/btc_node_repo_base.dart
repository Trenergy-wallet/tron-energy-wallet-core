import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Интерфейс BTC ноды
abstract interface class BTCNodeRepo {
  /// Get utxos for address - получить входы кошелька = Api v1
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  });

  /// Get utxos for address - получить входы кошелька = Api v2
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV2({
    required String address,
    bool? confirmed,
  });

  /// Информация о транзакции
  Future<Either<AppExceptionWithCode, TransactionBtcNode>> fetchTransaction({
    required String txId,
  });

  /// Временный метод для отправки транзакций (пока не будем делать через
  /// существующий 6.2)
  Future<Either<AppExceptionWithCode, String>> tmpSendRawTransaction({
    required String transactionRaw,
    required bool isTestnet,
  });
}
