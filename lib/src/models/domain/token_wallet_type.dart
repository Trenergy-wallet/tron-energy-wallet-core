/// Тип кошелька, который мы инициализируем для конкретного токена
///
/// [unknown] - если тип не задан, либо для заполнения поля по умолчанию в
/// остальных блокчейнов
///
/// [master] - главный токен на блокчейне (основной = ТРХ на ТРОН, ТОН на ТОН)
///
/// [child] - Дочерний токен-контракт (BTC на TRON, XP на ТОН и тд)
///
/// [stable] - Стейбл дочерний токен (USDT на ТОН)
enum TokenWalletType {
  /// Тип неопределен
  unknown(),

  /// Главный токен на блокчейне (основной = ТРХ на ТРОН, ТОН на ТОН)
  master(),

  /// Дочерний токен-контракт (BTC на TRON, XP на ТОН и тд)
  child(),

  /// Стейбл дочерний токен (USDT на ТОН)
  stable();

  const TokenWalletType();

  /// fromJson
  factory TokenWalletType.fromJson(dynamic json) => values.firstWhere(
        (e) => e.name == json.toString(),
        orElse: () => TokenWalletType.unknown,
      );

  /// toJson
  String toJson() => name;
}
