import 'package:on_chain/on_chain.dart';
import 'package:tron_energy_wallet_core/src/domain/models/account/local_account.cg.dart'
    show LocalAccount;

/// Abstract interface of the Core local repository
abstract interface class LocalRepoBaseCore {
  /// Select account
  Future<void> chooseAccount(LocalAccount account);

  /// Save account
  Future<void> saveAccount(LocalAccount account);

  /// Get account
  LocalAccount getAccount();

  /// Get accounts
  List<LocalAccount> getAccountList();

  /// Delete account
  Future<({bool lastAccountDeleted})> deleteAccount(LocalAccount account);

  /// Update account
  Future<void> updateAccount({
    String? name,
    String? description,
    String? iconPath,
    String? colorBg,
    bool? useShowPartnerPromo,
    String? token,
    bool? hasWalletRights,
  });

  /// Save mnemonic
  Future<void> saveMnemonic({
    required String mnemonic,
    required String publicKey,
    required String masterKey,
  });

  /// Get mnemonic
  ///
  /// success - string of 12 words
  /// failure - empty string
  Future<String> getMnemonic({
    required String publicKey,
    required String masterKey,
  });

  /// Save wallet private key
  Future<void> savePK({
    required String pk,
    required String publicKey,
    required String masterKey,
  });

  /// Retrieve wallet private key
  Future<TronPrivateKey?> getPK({
    required String publicKey,
    required String masterKey,
  });

  /// Save token
  Future<void> saveToken(String value);
}
