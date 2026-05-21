import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/on_chain.dart';
import 'package:tron_energy_wallet_core/src/features/networks/solana/domain/token_type.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// TransferParamsSOL
class TransferParamsSOL extends TransferParams {
  /// TransferParamsSOL
  ///
  /// [to] - address to send to
  /// [amount] - number of coins to send
  /// [message] - optional message to add to the transaction. Maximum len = 100
  const TransferParamsSOL({
    required super.to,
    required super.from,
    required super.amount,
    required this.chainId,
    required this.tokenDecimal,
    required super.tokenWalletType,
    this.tokenType = .unknown,
    this.usePriorityFee = false,
    this.priorityFee = 0,
    this.cuLimit = 0,
    this.tokenContractAddress,
    this.tokenName,
    super.message,
  }) : super(appBlockchain: AppBlockchain.solana);

  /// Chain ID
  final int chainId;

  /// Token decimal
  final int tokenDecimal;

  /// PriorityFee
  final int priorityFee;

  /// Use priority fee
  final bool usePriorityFee;

  /// The max amount of units consumed by the transaction
  final int cuLimit;

  /// Token contract
  final String? tokenContractAddress;

  /// Token name
  final String? tokenName;

  /// Token type from SolTokenType
  final SolTokenType tokenType;

  /// From as SolAddress
  SolAddress get solAddressFrom => SolAddress.unchecked(from);

  /// To as SolAddress
  SolAddress get solAddressTo => SolAddress.unchecked(to);

  /// TokenContractAddress as SolAddress?
  SolAddress? get tokenContractAddressSolAddress => tokenContractAddress != null
      ? SolAddress.unchecked(tokenContractAddress!)
      : null;

  /// All fee params for the tx are filled
  bool get finalized => !usePriorityFee || priorityFee > 0 || cuLimit > 0;

  /// Copy
  TransferParamsSOL copyWith({
    String? to,
    String? from,
    BigRational? amount,
    int? chainId,
    int? tokenDecimal,
    TokenWalletType? tokenWalletType,
    bool? usePriorityFee,
    int? priorityFee,
    int? cuLimit,
    String? tokenContractAddress,
    String? tokenName,
    String? message,
    SolTokenType? tokenType,
  }) => TransferParamsSOL(
    to: to ?? this.to,
    from: from ?? this.from,
    amount: amount ?? this.amount,
    chainId: chainId ?? this.chainId,
    tokenDecimal: tokenDecimal ?? this.tokenDecimal,
    tokenWalletType: tokenWalletType ?? this.tokenWalletType,
    usePriorityFee: usePriorityFee ?? this.usePriorityFee,
    priorityFee: priorityFee ?? this.priorityFee,
    cuLimit: cuLimit ?? this.cuLimit,
    tokenContractAddress: tokenContractAddress ?? this.tokenContractAddress,
    tokenName: tokenName ?? this.tokenName,
    message: message ?? this.message,
    tokenType: tokenType ?? this.tokenType,
  );
}
