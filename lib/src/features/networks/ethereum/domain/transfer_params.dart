import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// TransferParamsETH
class TransferParamsETH extends TransferParams {
  /// TransferParamsETH
  ///
  /// [to] - address to send to
  /// [amount] - number of coins to send
  /// [message] - optional message to add to the transaction
  /// [feeType] - Selected fee type (fast, slow)
  const TransferParamsETH({
    required super.to,
    required super.from,
    required super.amount,
    required this.chainId,
    required this.supportsEIP1559,
    required this.tokenDecimal,
    required super.tokenWalletType,
    this.feeType = CoreConsts.defaultEthFeeType,
    this.tokenContractAddress,
    this.tokenName,
    super.message,
    this.userApprovedFee,
  }) : super(appBlockchain: AppBlockchain.ethereum);

  /// FeeType
  final FeeType feeType;

  /// UserApprovedFee
  final EstimateFeeModel? userApprovedFee;

  /// Create EIP1559 transaction
  final bool supportsEIP1559;

  /// Chain ID
  final int chainId;

  /// Token decimal
  final int tokenDecimal;

  /// Token contract
  final String? tokenContractAddress;

  /// Token name
  final String? tokenName;
}
