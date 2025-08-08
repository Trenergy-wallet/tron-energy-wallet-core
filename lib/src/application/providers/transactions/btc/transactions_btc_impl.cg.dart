import 'dart:async';
import 'dart:math';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/bip32/slip10/bip32_slip10_secp256k1.dart';
import 'package:blockchain_utils/bip/bip/bip39/bip39_seed_generator.dart';
import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:meta/meta.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'enum.dart';

/// Сервис Transactions
///
/// Предоставляет сервисы по созданию и подписанию транзакций Bitcoin
///
/// [SingingKeyCreatorBTC] содержит общие переменные для этого сервиса и
/// сервиса расчета длины транзакции
class TransactionsServiceBTCImpl
    with SingingKeyCreatorBTC
    implements TransactionsService {
  /// Сервис Transactions
  ///
  /// Предоставляет сервисы по созданию и подписанию транзакций Bitcoin
  TransactionsServiceBTCImpl({
    required this.network,
    required LocalRepoBaseCore localRepo,
    required BTCNodeRepo btcNodeRepo,
    required Future<ErrOrTransactionInfo> Function({
      required String tx,
      required AppBlockchain appBlockchain,
      String? txFee,
    })
    postTransaction,
    required Future<ErrOrEstimateFee> Function({
      required double amount,
      required AppBlockchain appBlockchain,
      required TokenWalletType tokenWalletType,
      String? recipientAddress,
      String? tokenContractAddress,
    })
    estimateFee,
  }) : this.localRepo = localRepo,
       _postTransaction = postTransaction,
       this.btcNodeRepo = btcNodeRepo,
       _estimateFee = estimateFee;

  /// Блокчейн сервиса
  @override
  final AppBlockchain appBlockchain = AppBlockchain.bitcoin;

  /// Сеть биткоина для работы сервиса
  @override
  final BitcoinNetwork network;

  @override
  final String name = 'TransactionsServiceBTCImpl';

  /// Отправка транзакции
  final Future<ErrOrTransactionInfo> Function({
    required String tx,
    required AppBlockchain appBlockchain,
    String? txFee,
  })
  _postTransaction;

  @protected
  @override
  final BTCNodeRepo btcNodeRepo;

  @protected
  @override
  final LocalRepoBaseCore localRepo;

  /// 2.4. Estimate Tx Energy Fee
  ///
  /// Для биткоина в разделе fees выдает стоимость в sat/vB (сатоши за ОДИН
  /// виртуальный байт)
  final Future<ErrOrEstimateFee> Function({
    required double amount,
    required AppBlockchain appBlockchain,
    required TokenWalletType tokenWalletType,
    String? recipientAddress,
    String? tokenContractAddress,
  })
  _estimateFee;

  /// 6 Store (Broadcast)
  @override
  Future<TransactionInfoData> postTransactionOrThrow({
    required String tx,
    String? txFee,
  }) async {
    try {
      if (tx.isEmpty) {
        throw AppException(code: ExceptionCode.unableToCreateTransaction);
      }
      final res = await _postTransaction(tx: tx, appBlockchain: appBlockchain);

      return res.fold((l) => throw l, (r) => r);
    } on Exception catch (e) {
      logger.logCriticalError(name, 'postTransactionOrThrow: $e');
      rethrow;
    }
  }

  @override
  Future<String> createTransactionOrThrow({
    required String toAddress,
    required double amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    String? requestPinMessage,
    FeeTypeBTC? feeTypeBTC,
    String? txIdToPumpFeeBTC,
  }) async {
    String? signedTransaction;
    try {
      final (
        transactionVSize: transactionVSize,
        pendingTransactions: pendingTransactions,
        sumOfUtxo: sumOfUtxo,
        sumOfOutputs: sumOfOutputs,
        outPuts: outPuts,
        spender3Taproot: spender3Taproot,
        accountsUtxos: accountsUtxos,
        senderPrivateKey: senderPrivateKey,
        memo: memo,
        maxRbfTransactionFeeRatePer1B: maxRbfTransactionFeeRatePer1vB,
      ) = await prepareTransactionAndCalculateSizeOrThrow(
        toAddress: toAddress,
        amount: amount,
        asset: asset,
        masterKey: masterKey,
        message: message,
        txIdToPumpFeeBTC: txIdToPumpFeeBTC,
      );
      // 4.2 Стоимости комиссий из расчета на 1 байт получим от бэка
      final networkEstimate = (await _estimateFee(
        amount: amount,
        appBlockchain: appBlockchain,
        tokenWalletType: asset.token.tokenWalletType,
        tokenContractAddress: asset.token.contractAddress,
      )).fold((l) => throw l, (r) => r);
      if (networkEstimate.fees == Fees.invalid) {
        throw AppException(
          message: 'BTC fees are invalid: ${networkEstimate.fees}',
          code: ExceptionCode.amountIsNotPositive,
        );
      }
      // 4.3 Выберем нужную стоимость комисси в зависимости от того, что
      // выбрал пользователь в интерфейса
      // Если мы сюда дошли, то feeTypeBTC уже не null тк проверка была
      // проведена
      final feePer1vBCurent = networkEstimate.fees.feeForType(feeTypeBTC!);
      // Выбираем какую стоимость отправки комиссии использовать: ту, которая
      // сейчас есть в сети [feePer1vBCurent], либо ту, что уже была в rbf
      // транзакции
      final feePer1vB = max(feePer1vBCurent, maxRbfTransactionFeeRatePer1vB);

      // Это не особо нужная проверка - поидее это бэк следит
      if (feePer1vB < networkEstimate.fees.minimumFee) {
        throw AppException(
          message: 'Fee is too low: $feePer1vB',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }

      // 4.4 Финальная сумма комиссии
      final fee = BigInt.from(feePer1vB * transactionVSize);
      // 4.5 Если мы используем RBF входы обязательно нужно проверить
      // условие что комиссия в новой транзакции больше чем в предыдущей
      // RBF = транзакция с бОльшей комиссией заменяет транзакцию с
      // меньшей комиссией при условии что у них пересекаются входы
      final feesInReplacedRbfTransactions = pendingTransactions.fold(
        0,
        (prev, next) => prev + next.fees!,
      );
      if (BigInt.from(feesInReplacedRbfTransactions).compareTo(fee) >= 0) {
        throw AppException(
          message:
              'New transaction fee $fee is less or equal sum of '
              'replaced RBF transactions: $feesInReplacedRbfTransactions',
          code: ExceptionCode.unableToCreateTransaction,
        );
      }
      logger.logInfoMessage(
        name,
        'createTransactionOrThrow: fee per vB: $feePer1vB, total fee: '
        '$fee ${pendingTransactions.isNotEmpty ? ''
                  ', was $feesInReplacedRbfTransactions' : ''}',
      );
      // 5 Расчет сдачи
      // changeValue - что мы возвращаем обратно в ввиде сдачи
      final changeValue = sumOfUtxo - (sumOfOutputs + fee);
      logger.logInfoMessage(
        name,
        'createTransactionOrThrow: changeValue: $changeValue',
      );
      if (changeValue.isNegative || fee.isNegative) {
        throw AppException(
          message: 'Not enough balance: changeValue: $changeValue, fee: $fee',
          code: ExceptionCode.amountIsNotPositive,
        );
      }
      // 5.1 Если сдача положительная, добавляем ее в выходы на место
      // заглушки
      if (changeValue > BigInt.zero) {
        outPuts.add(
          BitcoinOutput(address: spender3Taproot, value: changeValue),
        );
      }
      // 6 Собираем транзакцию
      final builder = BitcoinTransactionBuilder(
        outPuts: outPuts,
        fee: fee,
        network: network,
        utxos: accountsUtxos,
        memo: memo,
        enableRBF: true,
      );
      final transaction = await builder.buildTransactionAsync((
        trDigest,
        utxo,
        publicKey,
        sigHash,
      ) async {
        if (utxo.utxo.isP2tr) {
          return senderPrivateKey.signBip340(trDigest, sighash: sigHash);
        }
        return senderPrivateKey.signECDSA(trDigest, sighash: sigHash);
      });

      final txId = transaction.txId();
      logger.logInfoMessage(name, 'createTransactionOrThrow: txId: $txId');
      signedTransaction = transaction.serialize();
      logger.logInfoMessage(
        name,
        'createTransactionOrThrow: signedTransaction: $signedTransaction',
      );
      if (signedTransaction.isEmpty) {
        throw AppException(code: ExceptionCode.unableToCreateTransaction);
      }
      return signedTransaction;
    } catch (e) {
      if (e is! IncorrectPinCodeException) {
        logger.logCriticalError(name, 'createTransactionOrThrow: $e');
      }
      rethrow;
    }
  }

  @override
  Future<({String address, List<int> pkAsBytes})>
  tryInitializeWalletAndGetInfoOrThrow({String? masterKey}) async {
    if (masterKey == null) {
      throw AppException(
        message: 'master key is null',
        code: ExceptionCode.unableToDecodeWallet,
      );
    }
    final pk = await createSigningKeyOrThrow(masterKey: masterKey);
    final publicKey = pk.getPublic();
    return (
      address: publicKey.toTaprootAddress().toAddress(network),
      pkAsBytes: pk.toBytes(),
    );
  }

  @override
  Future<bool?> checkWalletIsFrozen({
    required AppAsset asset,
    required String addressToCheck,
  }) async => false;
}

/// Класс для хранения метода создания ключа подписи биткоина
mixin SingingKeyCreatorBTC {
  AppBlockchain get appBlockchain;

  @protected
  String get name;

  @protected
  final InAppLogger logger = InAppLogger.instance;

  @protected
  LocalRepoBaseCore get localRepo;

  @protected
  BTCNodeRepo get btcNodeRepo;

  /// В какой сети работаем
  BitcoinNetwork get network;

  /// Создать ключ подписи для BTC
  Future<ECPrivate> createSigningKeyOrThrow({required String masterKey}) async {
    final mnemonicFromRepo = await localRepo
        // Берем текущий активный кошелек трона
        .getMnemonic(
          publicKey: localRepo.getAccount().publicKey,
          masterKey: masterKey,
        );
    if (mnemonicFromRepo.isEmpty) {
      throw AppException(code: ExceptionCode.unableToRetrieveMnemonic);
    }
    final mnemonicGenerated = Bip39SeedGenerator(
      Mnemonic.fromString(mnemonicFromRepo),
    ).generate();
    final bip32 = Bip32Slip10Secp256k1.fromSeed(mnemonicGenerated);
    // BIP-86 m/86'/0'/0'/0/0 - для taproot
    // BIP-84 m/84'/0'/0'/0/0 - для SegWit
    // BIP-49 "m/49'/0'/0'/0/0" - для SegWit в режиме совместимости со старыми кошельками
    final bipBase = bip32.derivePath(BtcBipPath.bip86taproot.path);
    return ECPrivate.fromBytes(bipBase.privateKey.raw);
  }

  /// Все вычисления которые мы вынуждены производить чтобы вычислить
  /// размер транзакции
  Future<
    ({
      int transactionVSize,
      List<TransactionBtcNode> pendingTransactions,
      BigInt sumOfUtxo,
      BigInt sumOfOutputs,
      List<BitcoinOutput> outPuts,
      P2trAddress spender3Taproot,
      List<UtxoWithAddress> accountsUtxos,
      ECPrivate senderPrivateKey,
      int maxRbfTransactionFeeRatePer1B,
      String? memo,
    })
  >
  prepareTransactionAndCalculateSizeOrThrow({
    required String toAddress,
    required double amount,
    required AppAsset asset,
    required String masterKey,
    String? message,
    String? txIdToPumpFeeBTC,
  }) async {
    if (asset.token.blockchain.appBlockchain != appBlockchain) {
      throw AppIncorrectBlockchainException(
        appBlockchain.toString(),
        asset.token.blockchain.appBlockchain.toString(),
      );
    }
    if (amount <= 0) {
      throw AppException(
        message:
            'unable to create transaction: amount is not positive: $amount',
        code: ExceptionCode.amountIsNotPositive,
      );
    }
    if (txIdToPumpFeeBTC != null && txIdToPumpFeeBTC.isEmpty) {
      throw AppException(
        message: 'Invalid txId for transaction to bump fee',
        code: ExceptionCode.unableToCreateTransaction,
      );
    }
    final senderPrivateKey = await createSigningKeyOrThrow(
      masterKey: masterKey,
    );
    switch (asset.token.tokenWalletType) {
      // Никакие типы кошельков кроме master (btc) не поддерживаются
      case TokenWalletType.child:
      case TokenWalletType.stable:
      case TokenWalletType.unknown:
        throw AppException(
          message: '${asset.token.tokenWalletType} is not supported',
          code: ExceptionCode.tokenIsNotSupported,
        );
      // Работаем с самим биткоином
      case TokenWalletType.master:
        logger.logInfoMessage(name, 'Creating btc transaction');
        final addressToSend = BitcoinAddress(
          toAddress,
          network: network,
        ).baseAddress;
        // Сообщение, которое будем записывать в транзакцию
        // для txIdToPumpFeeBTC мы его берем от ноды
        var messageToInclude = txIdToPumpFeeBTC == null ? message : null;

        final publicKey = senderPrivateKey.getPublic();
        // 1. Выбор спендрера
        // Берем ТОЛЬКО Taproot спендер
        final spender3Taproot = publicKey.toTaprootAddress();
        final spender3TaprootAddres = spender3Taproot.toAddress(network);
        // Проверяем что мы работаем с правильным кошельком
        if (asset.address != spender3TaprootAddres) {
          throw AppException(
            message:
                'Address from asset: ${asset.address}, address from '
                'account: ${spender3Taproot.toAddress(network)}',
            code: ExceptionCode.unableToDecodeWallet,
          );
        }
        // Мы можем забирать баланс из любого из них или из нескольких
        final spenders = <BitcoinBaseAddress>[spender3Taproot];
        logger.logInfoMessage(
          name,
          'Send from address: $spender3TaprootAddres',
        );
        // 2. Получение непотраченных выходов (UTXO)
        // Входы, которые будем тратить (Unspent Transaction Outputs)
        final accountsUtxos = <UtxoWithAddress>[];
        // Выходы, которые уже связаны в неподтвержденных транзакциях
        final pendingUtxos = <AppUtxo>[];

        // loop each spenders address and get utxos and add to accountsUtxos
        for (final i in spenders) {
          final utxosResponse = await btcNodeRepo.fetchUtxosV2(
            address: i.toAddress(network),
            confirmed: true,
          );
          // 2.1 Забираем входы у ноды
          final utxos = utxosResponse.fold((l) => throw l, (r) => r);
          // 2.2 Конвертируем их в модель для билдера
          final utxosWithAddress = utxos
              .map(
                (e) => UtxoWithAddress(
                  utxo: BitcoinUtxo(
                    txHash: e.txid,
                    value: e.value,
                    vout: e.vout,
                    scriptType: i.type,
                    blockHeight: e.height,
                  ),
                  ownerDetails: UtxoAddressDetails(
                    publicKey: publicKey.toHex(),
                    address: i,
                  ),
                ),
              )
              .toList();
          accountsUtxos.addAll(utxosWithAddress);
          // 2.3 Подготовим выходы для RBF
          // У ноды что стоит кэш, поэтому вынужденно запрашиваем подтвержденные
          // входы через v2 api а неподтвержденные через v1
          final pendingTransactionsResponse = await btcNodeRepo.fetchUtxosV1(
            address: i.toAddress(network),
            confirmed: false,
          );
          final utxosPending = pendingTransactionsResponse.fold(
            (l) => throw l,
            (r) => r,
          );
          pendingUtxos.addAll(utxosPending.where((e) => e.confirmations == 0));
        }
        if (pendingUtxos.isNotEmpty) {
          logger.logInfoMessage(
            name,
            'pending transactions: '
            '${pendingUtxos.map((e) => e.txid).join(',')}',
          );
        }
        // Сумма всех входов
        final sumOfUtxo = accountsUtxos.sumOfUtxosValue();
        logger.logInfoMessage(name, 'sumOfUtxo: $sumOfUtxo');
        // Нечего тратить
        if (sumOfUtxo == BigInt.zero) {
          throw AppException(
            message: 'sumOfUtxo is zero',
            code: ExceptionCode.amountIsNotPositive,
          );
        }

        logger.logInfoMessage(
          name,
          'will send to $spender3TaprootAddres on ${network.identifier}',
        );

        // 3. Сборка выходов (BitcoinOutput)
        // 3.1 Добавим основной выход транзакции
        final outPuts = <BitcoinOutput>[
          // Если мы только подрнимаем комиссию для txIdToPumpFeeBTC данный
          // выход не добавляем - данные транзакции будем забирать из
          // эндпоинта
          if (txIdToPumpFeeBTC == null)
            BitcoinOutput(
              address: addressToSend,
              value: BtcUtils.toSatoshi(amount.toString()),
            ),
        ];
        // 3.2 Добавим в выходы наши rbf неподтвержденные транзакции
        final pendingTransactions = <TransactionBtcNode>[];
        // 3.2.1 Получим информацию по каждой такой транзакции
        for (final utxo in pendingUtxos) {
          final txResponse = await btcNodeRepo.fetchTransaction(
            txId: utxo.txid,
          );
          txResponse.fold((l) => throw l, (r) {
            // Бывает что нода глючит и выдает как неподтвержденные уже
            // подтвержденные транзакции, проверим дополнительно, что
            // транзакция действительно еще не имеет подтверждений
            if (r.isPending) pendingTransactions.add(r);
          });
        }
        // 3.3 Очистим список транзакций от тех, которые используют входы
        // которые мы не задействуем
        pendingTransactions.retainWhere(
          (pt) => pt.vin.any(
            (v) =>
                accountsUtxos.any((accUtxo) => accUtxo.utxo.txHash == v.txId),
          ),
        );

        // Если запрошенной транзакции на поднятие комиссии нет в списке
        // неподтвержденных, уходим
        if (txIdToPumpFeeBTC != null &&
            !pendingTransactions.any((e) => e.txId == txIdToPumpFeeBTC)) {
          throw AppException(
            message:
                'Tx with id $txIdToPumpFeeBTC is not in pending transactions',
            code: ExceptionCode.unableToCreateTransaction,
          );
        }

        var maxRbfTransactionFeeRate = 0;

        // 3.4 Обработаем все оставшиеся неподтвержденные транзакции
        for (final pendingTransaction in pendingTransactions) {
          // Если не rbf транзакция заблокировала наши выходы то ничего не
          // можем сделать
          if (!pendingTransaction.rbf) {
            throw AppException(
              message:
                  'Non rbf transaction is pending: '
                  '${pendingTransaction.txId}',
              code: ExceptionCode.unableToCreateTransaction,
            );
          }
          // 3.5 Из ожидающих транзакций выбираем нужные нам выходы
          // message не берем тут (будет использоваться когда мы только
          // поднимаем комиссию существующей транзакции)
          final outputsRbfToAdd = pendingTransaction
              .onlyTransfersToOutputsOrThrow(
                network: network,
                includeMessage: txIdToPumpFeeBTC != null,
                senderAddress: spender3TaprootAddres,
              );
          // Тут мы должны посчитать с какой стоимостью отправлялась прошлая
          // транзакция
          if (outputsRbfToAdd.outputs.isNotEmpty &&
              pendingTransaction.fees != null) {
            // Везде для сравнения используем vSize
            // https://learnmeabitcoin.com/technical/transaction/size/
            maxRbfTransactionFeeRate = max(
              (pendingTransaction.fees! / pendingTransaction.vSize).ceil(),
              maxRbfTransactionFeeRate,
            );
            // Если у нас есть rbf транзакция, чьи входы мы используем, то
            // добавим еще 1 sat/vB чтобы она точно заместила предыдущую
            if (maxRbfTransactionFeeRate > 0) maxRbfTransactionFeeRate++;

            logger.logInfoMessage(
              '_SingingKeyCreatorBTC',
              'RBF maxRbfTransactionFeeRate = '
                  '$maxRbfTransactionFeeRate, tx: ${pendingTransaction.txId},'
                  ' fees: ${pendingTransaction.fees}, vSize: '
                  '${pendingTransaction.vSize}',
            );
          }

          // Сохраним в логе что мы конкретно хотим добавить в выходы
          for (final output in outputsRbfToAdd.outputs) {
            logger.logInfoMessage(
              name,
              'Will add output from '
              '${pendingTransaction.txId}: value ${output.value} to '
              '${output.address.toAddress(network)}',
            );
          }
          outPuts.addAll(outputsRbfToAdd.outputs);
          // Забирем комментарий если мы проводим только бамп комиссии
          if (pendingTransaction.txId == txIdToPumpFeeBTC) {
            messageToInclude = outputsRbfToAdd.message;
            if (messageToInclude != null) {
              logger.logInfoMessage(name, 'Use message: $messageToInclude');
            }
          }
        }
        // Не логично делать транзакцию только из одной сдачи, Что-то пошло
        // не так
        if (outPuts.isEmpty) {
          throw AppException(
            message: 'Outputs is empty',
            code: ExceptionCode.unableToCreateTransaction,
          );
        }
        // OP_RETURN
        final memo = convertMessageForOpReturn(messageToInclude);
        // SUM OF OUTOUT AMOUNTS
        final sumOfOutputs = outPuts.fold(
          BigInt.zero,
          (previousValue, element) => previousValue + element.value,
        );
        // 4 Расчет комиссии
        // 4.1 Расчет размера транзакции
        final transactionVSize =
            BitcoinTransactionBuilder.estimateTransactionSize(
              utxos: accountsUtxos,
              outputs: [
                ...outPuts,
                // Выход для зачисления сдачи - пока заглушка
                BitcoinOutput(address: spender3Taproot, value: BigInt.zero),
              ],
              network: network,
              // OP_RETURN
              memo: memo,
              // rbf - replace by fee
              enableRBF: true,
            );
        return (
          transactionVSize: transactionVSize,
          pendingTransactions: pendingTransactions,
          sumOfUtxo: sumOfUtxo,
          sumOfOutputs: sumOfOutputs,
          outPuts: outPuts,
          spender3Taproot: spender3Taproot,
          accountsUtxos: accountsUtxos,
          senderPrivateKey: senderPrivateKey,
          memo: memo,
          maxRbfTransactionFeeRatePer1B: maxRbfTransactionFeeRate,
        );
    }
  }
}
