// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../account_utxo.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUtxoDtoV2 _$AppUtxoDtoV2FromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AppUtxoDtoV2', json, ($checkedConvert) {
      final val = _AppUtxoDtoV2(
        txid: $checkedConvert('txid', (v) => v as String),
        vout: $checkedConvert('vout', (v) => (v as num).toInt()),
        value: $checkedConvert('value', (v) => v as String),
        confirmations: $checkedConvert(
          'confirmations',
          (v) => (v as num).toInt(),
        ),
        height: $checkedConvert('height', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AppUtxoDtoV2ToJson(_AppUtxoDtoV2 instance) =>
    <String, dynamic>{
      'txid': instance.txid,
      'vout': instance.vout,
      'value': instance.value,
      'confirmations': instance.confirmations,
      'height': instance.height,
    };

_AppUtxoDtoV1 _$AppUtxoDtoV1FromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AppUtxoDtoV1', json, ($checkedConvert) {
      final val = _AppUtxoDtoV1(
        txid: $checkedConvert('txid', (v) => v as String),
        vout: $checkedConvert('vout', (v) => (v as num).toInt()),
        satoshis: $checkedConvert('satoshis', (v) => (v as num).toInt()),
        confirmations: $checkedConvert(
          'confirmations',
          (v) => (v as num).toInt(),
        ),
        height: $checkedConvert('height', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AppUtxoDtoV1ToJson(_AppUtxoDtoV1 instance) =>
    <String, dynamic>{
      'txid': instance.txid,
      'vout': instance.vout,
      'satoshis': instance.satoshis,
      'confirmations': instance.confirmations,
      'height': instance.height,
    };
