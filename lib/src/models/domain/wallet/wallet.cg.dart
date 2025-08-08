import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/wallet.cg.f.dart';

/// Главный кошелек аккаунта TRON
///
/// [assets] - связанные с основным аккаунтом кошельки разных блокчейнов
@freezed
sealed class AppWallet with _$AppWallet {
  /// AppWallet
  ///
  /// [assets] - связанные с основным аккаунтом кошельки разных блокчейнов
  const factory AppWallet({
    required int id,
    required String address,
    required List<AppAsset> assets,
    required BlockchainInfo blockchain,
  }) = _AppWallet;
}

/// AppBlockchain
@freezed
sealed class BlockchainInfo with _$BlockchainInfo {
  /// AppBlockchain
  const factory BlockchainInfo({
    required int id,
    required String name,
    required String shortName,
    required String icon,
    required bool isNew,
    required List<AppToken> tokens,
    required AppBlockchain appBlockchain,
  }) = _BlockchainInfo;

  const BlockchainInfo._();

  /// Ошибочное/пустое состояние
  static const BlockchainInfo empty = BlockchainInfo(
    id: 0,
    name: '',
    shortName: '',
    icon: '',
    isNew: false,
    tokens: [],
    appBlockchain: AppBlockchain.unknown,
  );
}

/// AppCurrency
@freezed
sealed class AppCurrency with _$AppCurrency {
  /// AppCurrency
  const factory AppCurrency({
    required int id,
    required String name,
    required String code,
    required double usdRate,
    int? currentIndex,
  }) = _AppCurrency;

  /// Ошибочное/пустое состояние
  static const AppCurrency empty = AppCurrency(
    id: 1,
    name: 'United Arab Emirates Dirham',
    code: 'AED',
    usdRate: 0,
  );
}

/// AppAssets
@freezed
sealed class AppAsset with _$AppAsset {
  /// AppAssets
  const factory AppAsset({
    required int id,
    required double balance,
    required AppToken token,
    required String address,
    required int walletId,
    required String childWalletAddress,
  }) = _AppAsset;

  const AppAsset._();

  /// Если активный токен TRX
  bool get isTrx => token.isTrx;

  /// Если активный токен USDT
  bool get isUSDT => token.isUSDT;

  /// AppBlockchain
  AppBlockchain get appBlockchain => token.blockchain.appBlockchain;

  /// Ошибочное/пустое состояние
  static const AppAsset empty = AppAsset(
    id: CoreConsts.invalidIntValue,
    balance: CoreConsts.invalidDoubleValue,
    token: AppToken.empty,
    address: '',
    walletId: CoreConsts.invalidIntValue,
    childWalletAddress: '',
  );
}

/// AppTokens
@freezed
sealed class AppToken with _$AppToken {
  /// AppToken
  const factory AppToken({
    required int id,
    required String name,
    required String shortName,
    required String icon,
    required double usdPrice,
    required double prevPriceDiffPercent,
    required String contractAddress,
    required int decimal,
    required BlockchainInfo blockchain,
    required TokenWalletType tokenWalletType,
    required String description,
    required int precision,
    @Default(false) bool isAddedToAssets,
  }) = _AppToken;

  const AppToken._();

  /// Активный токен = TRX
  bool get isTrx =>
      shortName == CoreConsts.tron &&
      blockchain.appBlockchain == AppBlockchain.tron &&
      tokenWalletType == TokenWalletType.master;

  /// Активный токен = USDT
  bool get isUSDT =>
      shortName == CoreConsts.usdt &&
      blockchain.appBlockchain == AppBlockchain.tron;

  /// Пустое значение
  static const AppToken empty = AppToken(
    id: 0,
    name: '',
    shortName: '',
    icon: '',
    usdPrice: 0,
    prevPriceDiffPercent: 0,
    contractAddress: '',
    decimal: CoreConsts.invalidIntValue,
    blockchain: BlockchainInfo.empty,
    tokenWalletType: TokenWalletType.unknown,
    description: '',
    precision: 0,
  );
}
