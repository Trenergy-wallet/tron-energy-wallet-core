import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/transactions.cg.f.dart';

/// 6.2 Transaction Info
@freezed
sealed class TransactionInfoData with _$TransactionInfoData {
  /// 6.2 Transaction Info
  const factory TransactionInfoData(
      {required String txId,
      required String linkToBlockchain}) = _TransactionInfoData;
}

/// Either ExtendedErrors, TransactionInfoData
typedef ErrOrTransactionInfo
    = Either<AppExceptionWithCode, TransactionInfoData>;
