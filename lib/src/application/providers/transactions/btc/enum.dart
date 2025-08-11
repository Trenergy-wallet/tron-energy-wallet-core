/// bip32.derivePath params
enum BtcBipPath {
  /// For SegWit in compatibility mode with legacy wallets
  bip49segwit("m/49'/0'/0'/0/0"),

  /// SegWit
  bip84segwit("m/84'/0'/0'/0/0"),

  /// Taproot
  bip86taproot("m/86'/0'/0'/0/0");

  const BtcBipPath(this.path);

  /// Key derivation path
  final String path;
}
