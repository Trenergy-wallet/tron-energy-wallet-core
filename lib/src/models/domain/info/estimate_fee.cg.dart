import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/estimate_fee.cg.f.dart';

/// Модель комиссии блокчейна
@freezed
sealed class EstimateFeeModel with _$EstimateFeeModel {
  /// Модель комиссии блокчейна
  const factory EstimateFeeModel({
    required double fee,
    required double energy,
    required Fees fees, // <- Комиссии для биткоина
  }) = _EstimateFeeModel;

  const EstimateFeeModel._();

  /// Ошибочное/пустое состояние
  static const empty = EstimateFeeModel(
    fee: CoreConsts.invalidDoubleValue,
    energy: CoreConsts.invalidDoubleValue,
    fees: Fees.invalid,
  );
}

/// Набор комиссий для биткоина
@freezed
sealed class Fees with _$Fees {
  /// Набор комиссий для биткоина
  const factory Fees({
    required int fastestFee,
    required int halfHourFee,
    required int hourFee,
    required int economyFee,
    required int minimumFee,
  }) = _Fees;

  const Fees._();

  /// Выбрать соответствующую [FeeTypeBTC] комиссию
  int feeForType(FeeTypeBTC feeType) => switch (feeType) {
        FeeTypeBTC.fast => fastestFee,
        FeeTypeBTC.optimal => halfHourFee,
        FeeTypeBTC.economy => economyFee,
      };

  /// Ошибочное значение / заглушка
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
