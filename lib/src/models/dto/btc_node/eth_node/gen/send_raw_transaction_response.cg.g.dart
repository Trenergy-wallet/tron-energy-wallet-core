// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../send_raw_transaction_response.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendRawTransactionResponse _$SendRawTransactionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_SendRawTransactionResponse', json, ($checkedConvert) {
  final val = _SendRawTransactionResponse(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    result: $checkedConvert('result', (v) => v as String?),
    error: $checkedConvert('error', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$SendRawTransactionResponseToJson(
  _SendRawTransactionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'result': instance.result,
  'error': instance.error,
};
