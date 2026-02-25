import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart'
    show BigRational;
import 'package:tron_energy_wallet_core/src/domain/domain.dart';

/// Transfer transactions parameters
abstract class TransferParams {
  /// Transfer transactions parameters
  ///
  /// [to] - address to send to
  /// [amount] - number of coins to send
  /// [message] - optional message to add to the transaction
  const TransferParams({
    required this.to,
    required this.from,
    required this.amount,
    required this.appBlockchain,
    required this.tokenWalletType,
    this.message,
  });

  /// Address to send
  final String to;

  /// Address with balance to send
  final String from;

  /// Amount
  final BigRational amount;

  /// Blockchain of the asset
  final AppBlockchain appBlockchain;

  /// Type of the wallet to use
  final TokenWalletType tokenWalletType;

  /// Message to send
  final String? message;
}
