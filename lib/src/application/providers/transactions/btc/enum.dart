/// bip32.derivePath params
enum BtcBipPath {
  /// Для SegWit в режиме совместимости со старыми кошельками
  bip49segwit("m/49'/0'/0'/0/0"),

  /// SegWit
  bip84segwit("m/84'/0'/0'/0/0"),

  /// Taproot
  bip86taproot("m/86'/0'/0'/0/0");

  const BtcBipPath(this.path);

  /// Путь деривации ключа
  final String path;
}
