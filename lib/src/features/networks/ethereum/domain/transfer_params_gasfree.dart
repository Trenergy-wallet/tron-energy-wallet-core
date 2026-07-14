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
  /// [tokenWalletType] - тип токена от бэка ([TokenWalletType.child],
  /// [TokenWalletType.stable] и тд), но не [TokenWalletType.master]:
  /// gasfree применим только к токен-контрактам, не к нативной монете
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
         feeType: FeeType.gasfree,
       );

  /// Service fee in token units (null or zero - no service fee transfer)
  final BigRational? serviceFeeAmount;

  /// Address receiving the service fee
  ///
  /// Required when [serviceFeeAmount] is positive
  final String? serviceFeeCollector;
}
