/// Selected fee type for Bitcoin
enum FeeTypeBTC {
  /// Cheap and slow
  economy('mobile.slow'),

  /// Balanced
  optimal('mobile.optimal'),

  /// Fastest and most expensive
  fast('mobile.fast');

  const FeeTypeBTC(this.trKey);

  /// Key in translations
  final String trKey;
}
