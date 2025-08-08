import 'package:tron_energy_wallet_core/src/core/core.dart';
import 'package:tron_energy_wallet_core/src/models/models.dart';

export 'btc/transactions_btc_impl.cg.dart';
export 'ton/transactions_ton_impl.cg.dart';
export 'tron/transactions_tron_impl.cg.dart';

/// Сервис Transactions
///
/// Предоставляет сервисы по созданию и подписанию транзакций
interface class TransactionsService {
  /// Конструктор создания сервиса
  TransactionsService(this.appBlockchain);

  /// Блокчейн сервиса
  final AppBlockchain appBlockchain;

  /// Отправить транзакцию через наш бэк (6.2)
  ///
  /// Возвращает ссылку на открытие в блокчейне (все хорошо) или пустую строку
  /// (все плохо)
  Future<TransactionInfoData> postTransactionOrThrow({
    required String tx,
    String? txFee,
  }) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());

  /// Returns Signed transaction
  ///
  /// [toAddress] - адрес куда отправляем
  /// [amount] - количество монеток на отправку
  /// [asset] - кошелек
  /// [masterKey] - ключ доступа к данным на устройстве
  /// [message] - сообщение для добавления в транзакцию (опционально)
  /// [feeTypeBTC] - только биткоин. Выбранный тип комиссии (быстрая, медленная)
  /// [txIdToPumpFeeBTC] - только биткоин. Неподтвержденная транзакция, которой
  /// надо поднять комиссию. В данном случае toAddress, amount, message будут
  /// проигнорированы, тк данные будут браться из этой транзакции
  Future<String> createTransactionOrThrow({
    required String toAddress,
    required double amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    FeeTypeBTC? feeTypeBTC,
    String? txIdToPumpFeeBTC,
  }) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());

  /// Проверка инициализации кошелька
  ///
  /// String address = успешно
  /// null = не успешно
  ///
  /// Возврат приватного ключа нужен чтобы пользователь не
  /// вводил два раза подряд пинкод при отправке средств после смены аккаунта
  Future<({String address, List<int> pkAsBytes})>
  tryInitializeWalletAndGetInfoOrThrow({required String masterKey}) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());

  /// Проверка статуса кошелька (заморожен или нет)
  ///
  /// ТОЛЬКО для ТОН сети
  ///
  /// null если не удалось проверить статус
  Future<bool?> checkWalletIsFrozen({
    required AppAsset asset,
    required String addressToCheck,
  }) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());
}
