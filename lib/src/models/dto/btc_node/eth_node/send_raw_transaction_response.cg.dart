import 'package:freezed_annotation/freezed_annotation.dart';

part 'gen/send_raw_transaction_response.cg.f.dart';
part 'gen/send_raw_transaction_response.cg.g.dart';

/// SendRawTransactionResponse
@freezed
sealed class SendRawTransactionResponse with _$SendRawTransactionResponse {
  const factory SendRawTransactionResponse({
    required int id,
    String? result,
    Map<String, dynamic>? error,
  }) = _SendRawTransactionResponse;

  ///
  factory SendRawTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$SendRawTransactionResponseFromJson(json);
}
