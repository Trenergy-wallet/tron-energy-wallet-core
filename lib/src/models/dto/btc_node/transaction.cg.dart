import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/transaction.cg.f.dart';
part 'gen/transaction.cg.g.dart';

/// Модель для обращения к ноде за информацией о транзакции
@freezed
sealed class TransactionBtcNodeDto with _$TransactionBtcNodeDto {
  const factory TransactionBtcNodeDto({
    @JsonKey(name: 'txid') required String txId,
    // int? version,
    required List<VinDto> vin,
    required List<VoutDto> vout,
    @JsonKey(name: 'blockHeight') required int blockHeight,
    required int confirmations,
    required bool rbf,
    required String fees,
    required int size,
    @JsonKey(name: 'vsize') required int vSize,
  }) = _TransactionBtcNodeDto;

  const TransactionBtcNodeDto._();

  /// fromJson
  factory TransactionBtcNodeDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionBtcNodeDtoFromJson(json);

  /// TransactionBtcNodeDto => TransactionBtcNode
  TransactionBtcNode toDomainOrThrow() {
    return TransactionBtcNode(
      txId: txId,
      vin: vin.map((e) => e.toDomainOrThrow()).toList(),
      vout: vout.map((e) => e.toDomainOrThrow()).toList(),
      blockHeight: blockHeight,
      confirmations: confirmations,
      fees: int.parse(fees),
      rbf: rbf,
      size: size,
      vSize: vSize,
    );
  }
}

/// DTO входа Vin
@freezed
sealed class VinDto with _$VinDto {
  /// DTO входа Vin
  const factory VinDto({
    @JsonKey(name: 'txid') String? txId,
    // int? vout,
    int? sequence,
    int? n,
    List<String>? addresses,
    @JsonKey(name: 'isAddress') bool? isAddress,
    String? value,
  }) = _VinDto;

  const VinDto._();

  ///
  factory VinDto.fromJson(Map<String, dynamic> json) => _$VinDtoFromJson(json);

  /// VinDto => Vin
  Vin toDomainOrThrow() {
    return Vin(
      valueInSatoshi: int.parse(value!),
      n: n ?? CoreConsts.invalidIntValue,
      addresses: addresses!,
      isAddress: isAddress!,
      txId: txId!,
      // Приходит иногда null а мы его и не используем
      // vout: vout!,
      sequence: sequence!,
    );
  }
}

/// DTO выхода Vout
@freezed
sealed class VoutDto with _$VoutDto {
  /// DTO выхода Vout
  const factory VoutDto({
    /// DTO входа Vin
    String? value,
    int? n,
    String? hex,
    List<String>? addresses,
    @JsonKey(name: 'isAddress') bool? isAddress,
  }) = _VoutDto;

  const VoutDto._();

  ///
  factory VoutDto.fromJson(Map<String, dynamic> json) =>
      _$VoutDtoFromJson(json);

  /// VoutDto => Vout
  Vout toDomainOrThrow() {
    return Vout(
      valueInSatoshi: int.parse(value!),
      n: n ?? CoreConsts.invalidIntValue,
      hex: hex!,
      addresses: addresses!,
      isAddress: isAddress!,
    );
  }
}
