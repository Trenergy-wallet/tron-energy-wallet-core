/// Supported blockchains in the application
enum AppBlockchain {
  /// Unknown blockchain, not supported
  unknown('unknown', false, false, '', false),

  /// TRON
  tron('tron', true, true, 'TRX', false),

  /// TON
  ton('ton', true, false, 'TON', true),

  /// BTC
  bitcoin('bitcoin', true, false, 'BTC', true),

  /// ETH
  ethereum('ethereum', true, true, 'ETH', false);

  const AppBlockchain(
    this.slug,
    this.isSupported,
    this.allCoinsSupported,
    this.mainTokenName,
    this.supportsMemoMessage,
  );

  /// fromJson
  factory AppBlockchain.fromJson(dynamic json) => values.firstWhere(
    (e) => e.slug == json.toString(),
    orElse: () => AppBlockchain.unknown,
  );

  /// Blockchain slug on the backend. Must match the value from endpoint 2.1
  final String slug;

  /// Whether this blockchain is supported in the app
  final bool isSupported;

  /// True if all coins on the blockchain are handled the same way and fully
  /// supported (e.g., [tron])
  final bool allCoinsSupported;

  /// Token used to pay transaction fees
  final String mainTokenName;

  /// Whether a comment can be included in the transaction
  final bool supportsMemoMessage;

  /// toJson
  String toJson() => slug;
}
