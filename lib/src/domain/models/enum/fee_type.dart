/// Selected fee type
enum FeeType {
  /// Cheap and slow
  economy('mobile.slow'),

  /// Balanced
  optimal('mobile.optimal'),

  /// Fastest and most expensive
  fast('mobile.fast'),

  /// Gas is paid in the ERC-20 token being sent (EIP-7702 + ERC-20
  /// paymaster), no native coin needed on the sender
  gasFree('mobile.gasfree');

  const FeeType(this.trKey);

  /// Key in translations
  final String trKey;

  /// Gas is paid in the token itself (no native coin involved)
  bool get isGasFree => this == gasFree;
}
