import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// TransferParamsTRON
class TransferParamsTRON extends TransferParams {
  /// TransferParamsTRON
  ///
  /// [to] - address to send to
  /// [amount] - number of coins to send
  /// [message] - optional message to add to the transaction
  const TransferParamsTRON({
    required super.to,
    required super.from,
    required super.amount,
    required super.tokenWalletType,
    required this.tokenDecimal,
    required this.tokenContractAddress,
    super.message,
  }) : super(appBlockchain: AppBlockchain.tron);

  /// Token decimal
  final int tokenDecimal;

  /// Token contract
  final String? tokenContractAddress;
}
