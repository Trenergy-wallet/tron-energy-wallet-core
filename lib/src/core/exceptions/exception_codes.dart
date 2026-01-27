//
// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart' show DioException, DioExceptionType;

/// All exception codes
enum ExceptionCode {
  /// When it is not possible to specify the error in detail
  generalError(code: 'E1', description: 'General error'),
  noPrivateKeySaved(code: 'E2', description: 'No private key saved'),
  unableToDecodeWallet(code: 'E3', description: 'Unable to decode the wallet'),
  amountIsNotPositive(code: 'E4', description: 'Amount is not positive'),
  unableToRetrieveMnemonic(
    code: 'E5',
    description: 'Error while reading mnemonic from repo',
  ),
  // No TRON wallet in the account (e.g., failed to load)
  tronWalletNotLoadedToAccount(
    code: 'E6',
    description: 'Tron wallet is not loaded to the account',
  ),
  timeout(
    code: 'E7',
    description: 'Timeout',
  ),

  // Service initialization errors
  unableToInitializeWalletService(
    code: 'SI1',
    description: 'Initialisation error for WalletService',
  ),
  noJettonWallet(
    code: 'SI2',
    description: 'No jettonWalletAddress provided for master wallet',
  ),
  tokenIsNotSupported(code: 'SI3', description: 'Token is not supported'),

  // Fund sending errors
  blockchainLinkIsEmpty(
    code: 'TRS1',
    description: 'Service returned empty linkToBlockchain',
  ),
  unableToCreateTransaction(
    code: 'TRS2',
    description: 'Unable to create transaction',
  ),
  invalidCommissionAmount(
    code: 'TRS3',
    description: 'Invalid commission amount',
  ),
  unableToReceiveAssetToPayCommission(
    code: 'TRS4',
    description: 'Unable to retrieve the asset to pay commission',
  ),
  wrongToken(code: 'TRS5', description: 'Wrong token'),
  unableToReceiveTrxAsset(
    code: 'TRS6',
    description: 'Unable to retrieve the trx asset',
  ),
  // Transaction creation errors
  tronFromContractError(
    code: 'TRS7',
    description:
        'Something wrong here - TronRequestCreateTransaction.fromContract',
  ),
  feeChanged(
    code: 'TRS8',
    description: 'Network fee has changed',
  ),
  transitWalletError(
    code: 'T1',
    description: 'Error transit wallet is invalid',
  ),

  // Swap errors
  swapError(code: 'SW', description: 'Unknown error during swap'),
  swapControllerIsNotLoaded(
    code: 'SW1',
    description: 'Swap controller is not loaded',
  ),
  blockchainIsNotSupported(
    code: 'BS0',
    description: 'Blockchain is not supported',
  ),
  incorrectBlockchain(code: 'BS1', description: 'Incorrect blockchain'),

  // Backend errors
  backendGeneralError(code: 'B0', description: 'General backend error'),
  connectionTimeout(code: 'B1', description: 'Connection timeout'),
  responseDataIsNull(code: 'B2', description: 'Data is null in the response'),
  responseMetaIsNull(code: 'B3', description: 'Meta is null in the response'),
  checkedFromJsonException(
    code: 'B4',
    description: 'CheckedFromJsonException - backend sent different models',
  ),

  // Node and blockchain errors
  rpcError(code: 'RPC0', description: 'Blockchain node error'),

  // Staking exceptions
  stakingException(code: 'STK0', description: 'General staking error'),

  // Various types of exceptions where anything can be included in the
  // description
  rawException(
    code: 'R0',
    description: 'Raw exception. Message can be too big',
  )
  ;

  const ExceptionCode({required this.code, required this.description});

  /// DioException => ExceptionCode
  factory ExceptionCode.fromDioException(DioException? dioException) =>
      switch (dioException?.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError => connectionTimeout,
        _ => backendGeneralError,
      };

  /// Code to show to the user
  final String code;

  /// Error description
  final String description;

  @override
  String toString() => code;

  /// Timeout
  bool get isTimeout => this == connectionTimeout || this == timeout;
}
