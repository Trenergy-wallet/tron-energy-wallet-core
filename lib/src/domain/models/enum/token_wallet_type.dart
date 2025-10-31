/// Wallet type initialized for a specific token
///
/// [unknown] - if type is not set, or used as a default for other blockchains
///
/// [master] - main token on the blockchain (e.g., TRX on TRON, TON on TON)
///
/// [child] - child token contract (BTC on TRON, XP on TON, etc.)
///
/// [stable] - stable child token (USDT on TON)
enum TokenWalletType {
  /// Type undefined
  unknown(),

  /// Main token on the blockchain (e.g., TRX on TRON, TON on TON)
  master(),

  /// Child token contract (BTC on TRON, XP on TON, etc.)
  child(),

  /// Stable child token (USDT on TON)
  stable();

  const TokenWalletType();

  /// fromJson
  factory TokenWalletType.fromJson(dynamic json) => values.firstWhere(
    (e) => e.name == json.toString(),
    orElse: () => TokenWalletType.unknown,
  );

  /// toJson
  String toJson() => name;

  /// Master coin of the wallet
  bool get isMaster => this == master;
}
