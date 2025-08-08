// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart' show DioException, DioExceptionType;

/// Все коды исключений
///
enum ExceptionCode {
  /// Когда нет возможности детализировать ошибку
  generalError(code: 'E1', description: 'General error'),
  noPrivateKeySaved(code: 'E2', description: 'No private key saved'),
  unableToDecodeWallet(code: 'E3', description: 'Unable to decode the wallet'),
  amountIsNotPositive(code: 'E4', description: 'Amount is not positive'),
  unableToRetrieveMnemonic(
    code: 'E5',
    description: 'Error while reading mnemonic from repo',
  ),
  // В аккаунте нет кошелька ТРОН (не загрузился например)
  tronWalletNotLoadedToAccount(
    code: 'E6',
    description: 'Tron wallet is not loaded to the account',
  ),

  // Ошибки инициализации сервисов
  unableToInitializeWalletService(
    code: 'SI1',
    description: 'Initialisation error for WalletService',
  ),
  noJettonWallet(
    code: 'SI2',
    description: 'No jettonWalletAddress provided for master wallet',
  ),
  tokenIsNotSupported(code: 'SI3', description: 'Token is not supported'),

  // Ошибки отправок средств
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
  // Ошибки создания транзакции
  tronFromContractError(
    code: 'TRS7',
    description:
        'Something wrong here - TronRequestCreateTransaction.fromContract',
  ),
  transitWalletError(
    code: 'T1',
    description: 'Error transit wallet is invalid',
  ),

  // Ошибки свапа
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

  // Ошибки бэкенда
  backendGeneralError(code: 'B0', description: 'General backend error'),
  connectionTimeout(code: 'B1', description: 'Connection timeout'),
  responseDataIsNull(code: 'B2', description: 'Data is null in the response'),
  responseMetaIsNull(code: 'B3', description: 'Meta is null in the response'),
  checkedFromJsonException(
    code: 'B4',
    description: 'CheckedFromJsonException - backend sent different models',
  ),

  // Ошибки нод и блокчейнов
  rpcError(code: 'RPC0', description: 'Blockchain node error'),

  // Разные типы исключений куда в описание может упасть все что угодно.
  // НЕ показываем пользователю их сообщение
  rawException(
    code: 'R0',
    description: 'Raw exception. Message can be too big',
  );

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

  /// Код для показа пользователю
  final String code;

  /// Описание ошибки чтобы не запутаться
  final String description;

  @override
  String toString() => code;
}
