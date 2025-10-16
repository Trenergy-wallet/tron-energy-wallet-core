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
  }) = _EstimateFeeModel;

  const EstimateFeeModel._();

  /// Error value / placeholder
  static const empty = EstimateFeeModel(
    fee: CoreConsts.invalidDoubleValue,
    energy: CoreConsts.invalidDoubleValue,
    fees: Fees.invalid,
  );
}

/// Set of fees for Bitcoin
@freezed
sealed class Fees with _$Fees {
  const factory Fees({
    required int fastestFee,
    required int halfHourFee,
    required int hourFee,
    required int economyFee,
    required int minimumFee,
  }) = _Fees;

  const Fees._();

  /// Select the corresponding [FeeTypeBTC] fee
  int feeForType(FeeTypeBTC feeType) => switch (feeType) {
    FeeTypeBTC.fast => fastestFee,
    FeeTypeBTC.optimal => halfHourFee,
    FeeTypeBTC.economy => economyFee,
  };

  /// Error value / placeholder
  static const invalid = Fees(
    fastestFee: CoreConsts.invalidIntValue,
    halfHourFee: CoreConsts.invalidIntValue,
    hourFee: CoreConsts.invalidIntValue,
    economyFee: CoreConsts.invalidIntValue,
    minimumFee: CoreConsts.invalidIntValue,
  );
}

/// Either AppExceptionWithCode, EstimateFeeModel
typedef ErrOrEstimateFee = Either<AppExceptionWithCode, EstimateFeeModel>;
