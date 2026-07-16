import 'package:blockchain_utils/utils/utils.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// TransferParamsGasfreeETH
///
/// Params for a gasfree ERC-20 transfer: gas is paid in the token itself
/// via the Pimlico ERC-20 paymaster (EIP-7702), no native coin needed on
/// the sender.
///
/// [serviceFeeAmount] / [serviceFeeCollector] - optional service fee added
/// to the batch as a separate transfer of the same token
class TransferParamsGasfreeETH extends TransferParamsETH {
  /// TransferParamsGasfreeETH
  ///
  /// [tokenWalletType] - token type from the backend ([TokenWalletType.child],
  /// [TokenWalletType.stable] etc), but never [TokenWalletType.master]:
  /// gasfree is applicable to token contracts only, not to the native coin
  const TransferParamsGasfreeETH({
    required super.to,
    required super.from,
    required super.amount,
    required super.chainId,
    required super.tokenDecimal,
    required String super.tokenContractAddress,
    required super.tokenWalletType,
    this.serviceFeeAmount,
    this.serviceFeeCollector,
    super.tokenName,
  }) : assert(
         tokenWalletType != TokenWalletType.master,
         'gasfree is applicable to token contracts only',
       ),
       super(
         // UserOperations always use EIP-1559 style gas pricing
         supportsEIP1559: true,
         feeType: FeeType.gasFree,
       );

  /// Service fee in token units (null or zero - no service fee transfer)
  final BigRational? serviceFeeAmount;

  /// Address receiving the service fee
  ///
  /// Required when [serviceFeeAmount] is positive
  final String? serviceFeeCollector;
}
