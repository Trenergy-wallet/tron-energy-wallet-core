import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';
import 'package:tron_energy_wallet_core/src/domain/models/models.dart';

/// Transactions Service
///
/// Provides services for creating and signing transactions
interface class TransactionsService {
  /// Service constructor
  TransactionsService();

  /// Blockchain of the service
  AppBlockchain get appBlockchain => AppBlockchain.unknown;

  /// Send transaction through our backend (6.2)
  ///
  /// Returns a link to view the transaction on the blockchain (if successful)
  /// or an empty string (if failed)
  Future<TransactionInfoData> postTransactionOrThrow({
    required String tx,
    String? transactionType,
    int? operationId,
    String? txFee,
  }) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());

  /// Returns signed transaction
  ///
  /// [toAddress] - address to send to
  /// [amount] - number of coins to send
  /// [asset] - wallet
  /// [masterKey] - access key to data on the device
  /// [message] - optional message to add to the transaction
  /// [feeType] - Bitcoin only. Selected fee type (fast, slow)
  /// [txIdToPumpFeeBTC] - Bitcoin only. Unconfirmed transaction for which the
  /// fee needs to be bumped. In this case, [toAddress], [amount], and [message]
  /// will be ignored since data will be taken from this transaction
  Future<String> createTransactionOrThrow({
    required String toAddress,
    required BigRational amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    FeeType? feeType,
    EstimateFeeModel? userApprovedFee,
    String? txIdToPumpFeeBTC,
  }) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());

  /// Wallet initialization check
  ///
  /// String address = success
  /// null = failure
  ///
  /// Returning the private key is needed so the user doesn’t have to enter the
  /// PIN twice when sending funds after switching accounts
  Future<({String address, List<int> pkAsBytes})>
  tryInitializeWalletAndGetInfoOrThrow({required String masterKey}) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());

  /// Wallet status check (frozen or not)
  ///
  /// ONLY for the TON network
  ///
  /// null if the status could not be verified
  Future<bool?> checkWalletIsFrozen({
    required AppAsset asset,
    required String addressToCheck,
  }) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());
}
