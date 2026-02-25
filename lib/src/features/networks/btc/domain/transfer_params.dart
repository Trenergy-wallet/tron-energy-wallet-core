import 'package:tron_energy_wallet_core/src/domain/models/models.dart';

/// TransferParamsBTC
class TransferParamsBTC extends TransferParams {
  /// TransferParamsBTC
  ///
  /// [to] - address to send to
  /// [amount] - number of coins to send
  /// [message] - optional message to add to the transaction
  /// [feeType] - Selected fee type (fast, slow)
  /// [txIdToPumpFeeBTC] - Unconfirmed transaction for which the
  /// fee needs to be bumped. In this case, [to], [amount], and [message]
  /// will be ignored since data will be taken from this transaction
  const TransferParamsBTC({
    required super.to,
    required super.from,
    required super.amount,
    required super.tokenWalletType,
    required this.feeType,
    super.message,
    this.userApprovedFee,
    this.txIdToPumpFeeBTC,
  }) : super(appBlockchain: AppBlockchain.bitcoin);

  /// FeeType
  final FeeType feeType;

  /// UserApprovedFee
  final EstimateFeeModel? userApprovedFee;

  /// Unconfirmed transaction for which the
  /// fee needs to be bumped. In this case, [toAddress], [amount], and [message]
  /// will be ignored since data will be taken from this transaction
  final String? txIdToPumpFeeBTC;
}
