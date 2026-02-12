/// Supported blockchains in the application
enum AppBlockchain {
  /// Unknown blockchain, not supported
  unknown(
    slug: 'unknown',
    isSupported: false,
    allCoinsSupported: false,
    mainTokenName: '',
    supportsMemoMessage: false,
  ),

  /// TRON
  tron(
    slug: 'tron',
    isSupported: true,
    allCoinsSupported: true,
    mainTokenName: 'TRX',
    supportsMemoMessage: false,
  ),

  /// TON
  ton(
    slug: 'ton',
    isSupported: true,
    allCoinsSupported: false,
    mainTokenName: 'TON',
    supportsMemoMessage: true,
  ),

  /// BTC
  bitcoin(
    slug: 'bitcoin',
    isSupported: true,
    allCoinsSupported: false,
    mainTokenName: 'BTC',
    supportsMemoMessage: true,
  ),

  /// ETH
  ethereum(
    slug: 'ethereum',
    isSupported: true,
    allCoinsSupported: true,
    mainTokenName: 'ETH',
    supportsMemoMessage: false,
  ),

  /// BNB Smart Chain (EVM)
  bsc(
    slug: 'bnb',
    isSupported: true,
    allCoinsSupported: true,
    mainTokenName: 'BNB',
    supportsMemoMessage: false,
  ),

  /// Arbitrum Chain (EVM L2 Eth)
  arbitrum(
    slug: 'arbitrum',
    isSupported: true,
    allCoinsSupported: true,
    mainTokenName: 'ETH',
    supportsMemoMessage: false,
  ),

  /// Polygon (EVM)
  polygon(
    slug: 'polygon',
    isSupported: true,
    allCoinsSupported: true,
    mainTokenName: 'POL',
    supportsMemoMessage: false,
  ),

  /// Optimism Chain (EVM L2 Eth)
  optimism(
    slug: 'optimism',
    isSupported: true,
    allCoinsSupported: true,
    mainTokenName: 'ETH',
    supportsMemoMessage: false,
  )
  ;

  const AppBlockchain({
    required this.slug,
    required this.isSupported,
    required this.allCoinsSupported,
    required this.mainTokenName,
    required this.supportsMemoMessage,
  });

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

  /// Arbitrum
  ///
  /// L1 fee is included in eth_estimateGas
  bool get isArbitrum => this == arbitrum;

  /// Optimism
  bool get isOptimism => this == optimism;

  /// Polygon
  bool get isPolygon => this == polygon;

  /// toJson
  String toJson() => slug;
}
