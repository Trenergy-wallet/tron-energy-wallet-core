import 'package:freezed_annotation/freezed_annotation.dart';

part 'gen/local_account.cg.f.dart';
part 'gen/local_account.cg.g.dart';

/// AccountModel
///
/// Локальная модель аккаунта для хранения дополнительных данных при
/// авторизации и смене аккаунта
///
/// [address] - используется при авторизации для получения токена. ТРХ адрес
/// активного кошелька
///
/// [publicKey] - публичный ключ подписи - использется для хранения данных в
/// локальном репозитории
///
/// [token] - токен авторизации текущего аккаунта (кошелька ТРХ)
@Freezed(fromJson: true, toJson: true)
sealed class LocalAccount with _$LocalAccount {
  /// AccountModel
  ///
  /// Локальная модель аккаунта для хранения дополнительных данных при
  /// авторизации и смене аккаунта
  ///
  /// [address] - используется при авторизации для получения токена. ТРХ адрес
  /// активного кошелька
  ///
  /// [publicKey] - публичный ключ подписи - использется для хранения данных в
  /// локальном репозитории
  ///
  /// [token] - токен авторизации текущего аккаунта (кошелька ТРХ)
  const factory LocalAccount({
    required String name,
    required String description,
    required String iconPath,
    required String iconColorBg,
    required String address,
    required String publicKey,
    required String token,
    @Default(false) bool useFavorite,
    @Default(false) bool hasWalletRights,
    @Default(true) bool useShowPartnerPromo,
  }) = _LocalAccount;

  const LocalAccount._();

  /// AccountModel fromJson
  factory LocalAccount.fromJson(Map<String, dynamic> json) =>
      _$LocalAccountFromJson(json);

  /// Ошибочное/пустое состояние
  static const LocalAccount empty = LocalAccount(
    name: '',
    description: '',
    iconPath: '',
    address: '',
    publicKey: '',
    token: '',
    iconColorBg: '0xFFEDEDF2',
  );
}
