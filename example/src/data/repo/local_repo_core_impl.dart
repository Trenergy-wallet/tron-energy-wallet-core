import 'package:on_chain/tron/src/keys/private_key.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Example!!
///
/// For secure data storage, we recommend using flutter_secure_storage package
class LocalRepoImpl implements LocalRepoBaseCore {
  /// Singleton instance of LocalRepoImpl
  factory LocalRepoImpl() => _singleton;

  LocalRepoImpl._internal();

  static final LocalRepoImpl _singleton = LocalRepoImpl._internal();

  late String _mnemonic;
  late String _tronPk;
  late LocalAccount _localAccount;

  @override
  Future<void> chooseAccount(LocalAccount account) =>
      throw UnimplementedError();

  @override
  Future<({bool lastAccountDeleted})> deleteAccount(LocalAccount account) {
    throw UnimplementedError();
  }

  @override
  LocalAccount getAccount() => _localAccount;

  @override
  List<LocalAccount> getAccountList() => throw UnimplementedError();

  @override
  Future<String> getMnemonic({
    required String publicKey,
    required String masterKey,
  }) async => _mnemonic;

  @override
  Future<TronPrivateKey?> getPK({
    required String publicKey,
    required String masterKey,
  }) async {
    final stringNumbers = _tronPk.substring(1, _tronPk.length - 1).split(',');
    final numbers = stringNumbers
        .map((String str) => int.parse(str.trim()))
        .toList();
    return TronPrivateKey.fromBytes(numbers);
  }

  @override
  Future<void> saveAccount(LocalAccount account) async =>
      _localAccount = account;

  @override
  Future<void> saveMnemonic({
    required String mnemonic,
    required String publicKey,
    required String masterKey,
  }) async => _mnemonic = mnemonic;

  @override
  Future<void> savePK({
    required String pk,
    required String publicKey,
    required String masterKey,
  }) async => _tronPk = pk;

  @override
  Future<void> saveToken(String value) async => throw UnimplementedError();

  @override
  Future<void> updateAccount({
    String? name,
    String? description,
    String? iconPath,
    String? colorBg,
    bool? useShowPartnerPromo,
    String? token,
    bool? hasWalletRights,
  }) => throw UnimplementedError();
}
