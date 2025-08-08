/// Тип выбранной комиссии для биткоина
enum FeeTypeBTC {
  /// Дешево и медленно
  economy('mobile.slow'),

  /// Баланс
  optimal('mobile.optimal'),

  /// Быстрая и самая дорогая
  fast('mobile.fast');

  const FeeTypeBTC(this.trKey);

  /// Ключ в переводах
  final String trKey;
}
