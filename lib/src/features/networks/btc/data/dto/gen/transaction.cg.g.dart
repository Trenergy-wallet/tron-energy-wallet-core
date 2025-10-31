// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../transaction.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionBtcNodeDto _$TransactionBtcNodeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_TransactionBtcNodeDto', json, ($checkedConvert) {
  final val = _TransactionBtcNodeDto(
    txId: $checkedConvert('txid', (v) => v as String),
    vin: $checkedConvert(
      'vin',
      (v) => (v as List<dynamic>)
          .map((e) => VinDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    vout: $checkedConvert(
      'vout',
      (v) => (v as List<dynamic>)
          .map((e) => VoutDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    blockHeight: $checkedConvert('blockHeight', (v) => (v as num).toInt()),
    confirmations: $checkedConvert('confirmations', (v) => (v as num).toInt()),
    rbf: $checkedConvert('rbf', (v) => v as bool),
    fees: $checkedConvert('fees', (v) => v as String),
    size: $checkedConvert('size', (v) => (v as num).toInt()),
    vSize: $checkedConvert('vsize', (v) => (v as num).toInt()),
  );
  return val;
}, fieldKeyMap: const {'txId': 'txid', 'vSize': 'vsize'});

Map<String, dynamic> _$TransactionBtcNodeDtoToJson(
  _TransactionBtcNodeDto instance,
) => <String, dynamic>{
  'txid': instance.txId,
  'vin': instance.vin.map((e) => e.toJson()).toList(),
  'vout': instance.vout.map((e) => e.toJson()).toList(),
  'blockHeight': instance.blockHeight,
  'confirmations': instance.confirmations,
  'rbf': instance.rbf,
  'fees': instance.fees,
  'size': instance.size,
  'vsize': instance.vSize,
};

_VinDto _$VinDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_VinDto', json, ($checkedConvert) {
      final val = _VinDto(
        txId: $checkedConvert('txid', (v) => v as String?),
        sequence: $checkedConvert('sequence', (v) => (v as num?)?.toInt()),
        n: $checkedConvert('n', (v) => (v as num?)?.toInt()),
        addresses: $checkedConvert(
          'addresses',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        isAddress: $checkedConvert('isAddress', (v) => v as bool?),
        value: $checkedConvert('value', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'txId': 'txid'});

Map<String, dynamic> _$VinDtoToJson(_VinDto instance) => <String, dynamic>{
  'txid': instance.txId,
  'sequence': instance.sequence,
  'n': instance.n,
  'addresses': instance.addresses,
  'isAddress': instance.isAddress,
  'value': instance.value,
};

_VoutDto _$VoutDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_VoutDto', json, ($checkedConvert) {
      final val = _VoutDto(
        value: $checkedConvert('value', (v) => v as String?),
        n: $checkedConvert('n', (v) => (v as num?)?.toInt()),
        hex: $checkedConvert('hex', (v) => v as String?),
        addresses: $checkedConvert(
          'addresses',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        isAddress: $checkedConvert('isAddress', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$VoutDtoToJson(_VoutDto instance) => <String, dynamic>{
  'value': instance.value,
  'n': instance.n,
  'hex': instance.hex,
  'addresses': instance.addresses,
  'isAddress': instance.isAddress,
};
