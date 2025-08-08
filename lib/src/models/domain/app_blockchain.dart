/// Поддерживаемые блокчейны в приложении
enum AppBlockchain {
  /// Неизвестный блокчейн, не поддерживается
  unknown('unknown', false, false, '', false),

  /// TRON
  tron('tron', true, true, 'TRX', false),

  /// TON
  ton('ton', true, false, 'TON', true),

  /// BTC
  bitcoin('bitcoin', true, false, 'BTC', true),

  /// ETH
  ethereum('ethereum', false, false, '', false);

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

  /// Slug блокчейна на бэке. Дожно совпадать со значением из эндпоинта 2.1
  final String slug;

  /// Поддерживается ли работа данного блокчейна в приложении
  final bool isSupported;

  /// True если все монеты на блокчейне обрабатываются одинаково и мы их все
  /// поддерживаем (например [tron])
  final bool allCoinsSupported;

  /// Токен в котором списывается комиссия
  final String mainTokenName;

  /// Можно ли указывать комментарий в транзакции
  final bool supportsMemoMessage;

  /// toJson
  String toJson() => slug;
}
