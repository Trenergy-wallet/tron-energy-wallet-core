import 'package:freezed_annotation/freezed_annotation.dart';

part 'gen/local_account.cg.f.dart';
part 'gen/local_account.cg.g.dart';

/// AccountModel
///
/// Local account model for storing additional data during
/// authorization and account switching
///
/// [address] - used during authorization to obtain the token. TRX address
/// of the active wallet
///
/// [publicKey] - signature public key - used to store data in
/// the local repository
///
/// [token] - authorization token of the current account (TRX wallet)
@Freezed(fromJson: true, toJson: true)
sealed class LocalAccount with _$LocalAccount {
  /// AccountModel
  ///
  /// Local account model for storing additional data during
  /// authorization and account switching
  ///
  /// [address] - used during authorization to obtain the token. TRX address
  /// of the active wallet
  ///
  /// [publicKey] - signature public key - used to store data in
  /// the local repository
  ///
  /// [token] - authorization token of the current account (TRX wallet)
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

  /// Empty state
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
