import 'package:tron_energy_wallet_core/src/domain/domain.dart';

/// Core constants live here
class CoreConsts {
  /// TRX
  static const trx = 'TRX';

  /// TRON
  static const tron = 'TRON';

  /// USDT
  static const usdt = 'USDT';

  /// BTC
  static const btc = 'BTC';

  /// ETH
  static const ethereum = 'ETH';

  /// Error value -1 for int
  static const invalidIntValue = -1;

  /// Error value -1 for double
  static const invalidDoubleValue = -1.0;

  /// Contract address for USDT on TRON Mainnet
  static const contractUSDTonMainnet = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';

  /// Contract address for USDT on TRON Nile testnet
  static const contractUSDTonNile = 'TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf';

  /// How many blocks are used to calculate the fee
  static const ethBlockCountForFee = 25;

  /// Percentiles for fee calculation
  static const List<double> ethRewardPercentilesForFee = [25, 50, 90];

  /// Default ethereum FeeType if it was not selected
  static const FeeType defaultEthFeeType = FeeType.optimal;

  /// Еth decimals
  static const ethDecimals = 16;
}
