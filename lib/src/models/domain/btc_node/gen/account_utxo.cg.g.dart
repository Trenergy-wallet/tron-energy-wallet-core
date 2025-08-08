// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../account_utxo.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUtxo _$AppUtxoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AppUtxo', json, ($checkedConvert) {
      final val = _AppUtxo(
        txid: $checkedConvert('txid', (v) => v as String),
        vout: $checkedConvert('vout', (v) => (v as num).toInt()),
        value: $checkedConvert('value', (v) => BigInt.parse(v as String)),
        height: $checkedConvert('height', (v) => (v as num).toInt()),
        confirmations: $checkedConvert(
          'confirmations',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AppUtxoToJson(_AppUtxo instance) => <String, dynamic>{
  'txid': instance.txid,
  'vout': instance.vout,
  'value': instance.value.toString(),
  'height': instance.height,
  'confirmations': instance.confirmations,
};
