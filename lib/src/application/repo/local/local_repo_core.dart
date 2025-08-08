import 'package:on_chain/on_chain.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Абстрактный интерфейс локальной репы Core
abstract interface class LocalRepoBaseCore {
  /// Выбрать аккаунт
  Future<void> chooseAccount(LocalAccount account);

  /// Сохраняем аккаунт
  Future<void> saveAccount(LocalAccount account);

  /// Получаем аккаунт
  LocalAccount getAccount();

  /// Получаем аккаунты
  List<LocalAccount> getAccountList();

  /// Удаляем аккаунты
  Future<({bool lastAccountDeleted})> deleteAccount(LocalAccount account);

  /// Обновить аккаунт
  Future<void> updateAccount({
    String? name,
    String? description,
    String? iconPath,
    String? colorBg,
    bool? useShowPartnerPromo,
    String? token,
    bool? hasWalletRights,
  });

  /// Сохраняем mnemonic
  Future<void> saveMnemonic({
    required String mnemonic,
    required String publicKey,
    required String masterKey,
  });

  /// Получить mnemonic
  ///
  /// успех - строка 12 слов
  /// неудача - пустая строка
  Future<String> getMnemonic({
    required String publicKey,
    required String masterKey,
  });

  /// Сохранить приватный ключ кошелька
  Future<void> savePK({
    required String pk,
    required String publicKey,
    required String masterKey,
  });

  /// Достать приватный ключ кошелька
  Future<TronPrivateKey?> getPK({
    required String publicKey,
    required String masterKey,
  });

  /// Сохраняем token
  Future<void> saveToken(String value);
}
