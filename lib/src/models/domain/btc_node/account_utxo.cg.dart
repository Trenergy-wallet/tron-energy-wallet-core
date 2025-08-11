import 'package:freezed_annotation/freezed_annotation.dart';

part 'gen/account_utxo.cg.f.dart';
part 'gen/account_utxo.cg.g.dart';

// "txid": "e7d0b02d316468c5cc429e31de051d8508c90d65539ebba5703a0973a577daaa",
// "vout": 1,
// "value": "2000",
// "height": 900608,
// "confirmations": 12

/// AccountUtxo for Bitcoin
@freezed
sealed class AppUtxo with _$AppUtxo {
  /// AccountUtxo for Bitcoin
  const factory AppUtxo({
    required String txid,
    required int vout,
    required BigInt value,
    required int height,
    required int confirmations,
  }) = _AppUtxo;

  const AppUtxo._();

  /// fromJson
  factory AppUtxo.fromJson(Map<String, dynamic> json) =>
      _$AppUtxoFromJson(json);
}
