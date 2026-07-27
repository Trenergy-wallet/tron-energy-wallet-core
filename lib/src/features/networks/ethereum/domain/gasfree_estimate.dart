import 'package:blockchain_utils/utils/utils.dart';

/// Cacheable result of a precise gasfree operation estimation
///
/// A single paid Pimlico round (token quote + gas prices + paymaster stub +
/// gas estimation) provides everything needed both to display the fee and
/// to assemble the final UserOperation at send time. Gas limits do not
/// depend on the transfer amount, so the estimate survives amount changes
/// and is invalidated only by TTL or a profile change
/// (asset / sender / delegation installed)
class GasfreeEstimate {
  /// Cacheable result of a precise gasfree operation estimation
  const GasfreeEstimate({
    required this.chainId,
    required this.senderAddress,
    required this.tokenContractAddress,
    required this.includesServiceFee,
    required this.paymasterAddress,
    required this.stubPaymasterData,
    required this.exchangeRate,
    required this.postOpGas,
    required this.callGasLimit,
    required this.verificationGasLimit,
    required this.preVerificationGas,
    required this.paymasterVerificationGasLimit,
    required this.paymasterPostOpGasLimit,
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    required this.needsDelegation,
    required this.maxCostInToken,
    required this.expectedFeeInToken,
    required this.createdAt,
  });

  //== Estimation profile (validated against the params at send time) ==//

  /// Chain ID
  final int chainId;

  /// Sender address (EOA)
  final String senderAddress;

  /// Contract of the token being sent
  final String tokenContractAddress;

  /// Whether a separate service fee transfer is included in the estimate
  final bool includesServiceFee;

  //== ERC-20 paymaster quote ==//

  /// Paymaster address
  final String paymasterAddress;

  /// Stub paymasterData (to assemble the op before the final
  /// pm_getPaymasterData)
  final String stubPaymasterData;

  /// Token/gas exchange rate (from pimlico_getTokenQuotes)
  final BigInt exchangeRate;

  /// Gas of the paymaster postOp phase (from the quote)
  final BigInt postOpGas;

  //== Gas limits (eth_estimateUserOperationGas) ==//

  ///
  final BigInt callGasLimit;

  ///
  final BigInt verificationGasLimit;

  ///
  final BigInt preVerificationGas;

  ///
  final BigInt paymasterVerificationGasLimit;

  ///
  final BigInt paymasterPostOpGasLimit;

  //== Gas prices (pimlico_getUserOperationGasPrice) ==//

  /// Max gas price (fast) - the op is submitted with it
  final BigInt maxFeePerGas;

  /// Priority gas price (fast)
  final BigInt maxPriorityFeePerGas;

  //== Results ==//

  /// The EIP-7702 delegation is not installed yet (first operation)
  final bool needsDelegation;

  /// Maximum cost in token base units - the paymaster gets an approve for
  /// this amount, the actual charge is noticeably lower
  final BigInt maxCostInToken;

  /// Expected fee in token units (for display)
  final BigRational expectedFeeInToken;

  /// Moment the estimate was created (TTL is controlled by the caller)
  final DateTime createdAt;

  @override
  String toString() =>
      'GasfreeEstimate(chainId: $chainId, sender: $senderAddress, '
      'token: $tokenContractAddress, needsDelegation: $needsDelegation, '
      'expectedFee: $expectedFeeInToken, maxCostInToken: $maxCostInToken, '
      'createdAt: $createdAt)';
}
