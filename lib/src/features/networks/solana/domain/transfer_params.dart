import 'package:on_chain/on_chain.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// TransferParamsSOL
class TransferParamsSOL extends TransferParams {
  /// TransferParamsSOL
  ///
  /// [to] - address to send to
  /// [amount] - number of coins to send
  /// [message] - optional message to add to the transaction
  const TransferParamsSOL({
    required super.to,
    required super.from,
    required super.amount,
    required this.chainId,
    required this.tokenDecimal,
    required super.tokenWalletType,
    this.tokenContractAddress,
    this.tokenName,
    super.message,
  }) : super(appBlockchain: AppBlockchain.solana);

  /// Chain ID
  final int chainId;

  /// Token decimal
  final int tokenDecimal;

  /// Token contract
  final String? tokenContractAddress;

  /// Token name
  final String? tokenName;

  /// From as SolAddress
  SolAddress get fromSolAddress => SolAddress.unchecked(from);

  /// To as SolAddress
  SolAddress get toSolAddress => SolAddress.unchecked(to);

  /// TokenContractAddress as SolAddress?
  SolAddress? get tokenContractAddressSolAddress => tokenContractAddress != null
      ? SolAddress.unchecked(tokenContractAddress!)
      : null;
}
