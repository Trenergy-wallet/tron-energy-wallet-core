import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/estimate_fee.cg.f.dart';

/// Blockchain fee model
@freezed
sealed class EstimateFeeModel with _$EstimateFeeModel {
  /// Blockchain fee model
  const factory EstimateFeeModel({
    required double fee,
    required double energy,
    required Fees fees, // <- for btc
    required BigInt txDustThreshold,
  }) = _EstimateFeeModel;

  const EstimateFeeModel._();

  /// Error value / placeholder
  static final empty = EstimateFeeModel(
    fee: CoreConsts.invalidDoubleValue,
    energy: CoreConsts.invalidDoubleValue,
    fees: Fees.invalid,
    txDustThreshold: BigInt.zero,
  );
}

/// Set of fees for Bitcoin
@freezed
sealed class Fees with _$Fees {
  const factory Fees({
    required int fastestFee,
    required int halfHourFee,
    required int economyFee,
  }) = _Fees;

  const Fees._();

  /// Select the corresponding [FeeType] fee
  int feeForType(FeeType feeType) => switch (feeType) {
    FeeType.fast => fastestFee,
    FeeType.optimal => halfHourFee,
    FeeType.economy => economyFee,
  };

  /// Error value / placeholder
  static const invalid = Fees(
    fastestFee: CoreConsts.invalidIntValue,
    halfHourFee: CoreConsts.invalidIntValue,
    economyFee: CoreConsts.invalidIntValue,
  );
}

/// Either AppExceptionWithCode, EstimateFeeModel
typedef ErrOrEstimateFee = Either<AppExceptionWithCode, EstimateFeeModel>;
