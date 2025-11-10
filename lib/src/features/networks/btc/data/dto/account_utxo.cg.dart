import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/account_utxo.cg.f.dart';
part 'gen/account_utxo.cg.g.dart';

// "txid": "e7d0b02d316468c5cc429e31de051d8508c90d65539ebba5703a0973a577daaa",
// "vout": 1,
// "value": "2000",
// "height": 900608,
// "confirmations": 12

/// AccountUtxo для Bitcoin
@freezed
sealed class AppUtxoDtoV2 with _$AppUtxoDtoV2 {
  /// AccountUtxo для Bitcoin
  const factory AppUtxoDtoV2({
    required String txid,
    required int vout,
    required String value,
    required int confirmations,
    int? height,
  }) = _AppUtxoDtoV2;

  const AppUtxoDtoV2._();

  /// fromJson
  factory AppUtxoDtoV2.fromJson(Map<String, dynamic> json) =>
      _$AppUtxoDtoV2FromJson(json);

  /// AccountUtxoDtoV2 => AccountUtxo
  AppUtxo toDomainOrThrow() => AppUtxo(
        txid: txid,
        vout: vout,
        value: BigInt.parse(value),
        height: height ?? CoreConsts.invalidIntValue,
        confirmations: confirmations,
      );
}

/// AccountUtxo для Bitcoin
@freezed
sealed class AppUtxoDtoV1 with _$AppUtxoDtoV1 {
  /// AccountUtxo для Bitcoin
  const factory AppUtxoDtoV1({
    required String txid,
    required int vout,
    required int satoshis,
    required int confirmations,
    int? height,
  }) = _AppUtxoDtoV1;

  const AppUtxoDtoV1._();

  /// fromJson
  factory AppUtxoDtoV1.fromJson(Map<String, dynamic> json) =>
      _$AppUtxoDtoV1FromJson(json);

  /// AccountUtxoDtoV1 => AccountUtxo
  AppUtxo toDomainOrThrow() => AppUtxo(
        txid: txid,
        vout: vout,
        value: BigInt.from(satoshis),
        confirmations: confirmations,
        height: height ?? CoreConsts.invalidIntValue,
      );
}
