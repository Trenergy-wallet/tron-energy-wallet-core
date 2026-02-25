import 'package:tron_energy_wallet_core/src/core/core.dart';
import 'package:tron_energy_wallet_core/src/domain/models/models.dart';

/// Transactions Service
///
/// Provides services for creating and signing transactions
interface class TransactionsService<T extends TransferParams> {
  /// Service constructor
  TransactionsService();

  /// Blockchain of the service
  AppBlockchain get appBlockchain => AppBlockchain.unknown;

  /// Returns signed transaction or THROW
  Future<String> createTransaction({
    required T params,
    required String masterKey,
    // required String toAddress,
    // required BigRational amount,
    // required AppAsset asset,
    // required String masterKey,
    // String? message,
    // FeeType? feeType,
    // EstimateFeeModel? userApprovedFee,
    // String? txIdToPumpFeeBTC,
  }) async =>
      throw AppBlockchainIsNotSupportedException(appBlockchain.toString());

  /// Wallet initialization check
  ///
  /// String address = success
  /// null = failure
  ///
  /// Returning the private key is needed so the user doesn’t have to enter the
  /// PIN twice when sending funds after switching accounts
  Future<({String address, List<int> pkAsBytes})> initializeWalletAndGetInfo({
    required String masterKey,
  }) async =>
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
