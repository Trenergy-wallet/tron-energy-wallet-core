/// Selected fee type
enum FeeType {
  /// Cheap and slow
  economy('mobile.slow'),

  /// Balanced
  optimal('mobile.optimal'),

  /// Fastest and most expensive
  fast('mobile.fast');

  const FeeType(this.trKey);

  /// Key in translations
  final String trKey;
}
