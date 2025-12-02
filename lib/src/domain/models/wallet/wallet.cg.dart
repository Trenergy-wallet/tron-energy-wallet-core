import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/wallet.cg.f.dart';

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
    required bool supportsEIP1559,
    required int chainId,
    required int networkId,
  }) = _BlockchainInfo;

  const BlockchainInfo._();

  /// Error/empty state
  static const BlockchainInfo empty = BlockchainInfo(
    id: 0,
    name: '',
    shortName: '',
    icon: '',
    isNew: false,
    tokens: [],
    appBlockchain: AppBlockchain.unknown,
    supportsEIP1559: false,
    chainId: CoreConsts.invalidIntValue,
    networkId: CoreConsts.invalidIntValue,
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

  /// Error/empty state
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
    required double hold,
    required AppToken token,
    required String address,
    required int walletId,
    required String childWalletAddress,
  }) = _AppAsset;

  const AppAsset._();

  /// Active token is TRX
  bool get isTrx => token.isTrx;

  /// Active token is USDT
  bool get isUSDT => token.isUSDT;

  /// Active token is BTC
  bool get isBTC => token.isBTC;

  /// Active token is Ethereum
  bool get isEthereum => token.isEthereum;

  /// AppBlockchain
  AppBlockchain get appBlockchain => token.blockchain.appBlockchain;

  /// Balance with hold
  double get availableBalance => (balance - hold).clamp(0, double.nan);

  /// Coin to pay fees
  bool get isMasterWalletForBlockchain =>
      token.tokenWalletType == TokenWalletType.master;

  /// Error/empty state
  static const AppAsset empty = AppAsset(
    id: CoreConsts.invalidIntValue,
    balance: CoreConsts.invalidDoubleValue,
    hold: CoreConsts.invalidDoubleValue,
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

  /// Active token is TRX
  bool get isTrx =>
      blockchain.appBlockchain == AppBlockchain.tron &&
      tokenWalletType == TokenWalletType.master &&
      contractAddress.isEmpty;

  /// Active token is USDT
  bool get isUSDT =>
      blockchain.appBlockchain == AppBlockchain.tron &&
      [
        CoreConsts.contractUSDTonMainnet,
        CoreConsts.contractUSDTonNile,
      ].contains(contractAddress);

  /// Active token is BTC
  bool get isBTC =>
      blockchain.appBlockchain == AppBlockchain.bitcoin &&
      tokenWalletType == TokenWalletType.master &&
      contractAddress.isEmpty;

  /// Active token is Ethereum
  bool get isEthereum =>
      blockchain.appBlockchain == AppBlockchain.ethereum &&
      tokenWalletType == TokenWalletType.master &&
      contractAddress.isEmpty;

  /// Error/empty state
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
