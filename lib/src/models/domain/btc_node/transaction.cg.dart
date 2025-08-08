import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/transaction.cg.f.dart';

/// Модель для обращения к ноде за информацией о транзакции
@freezed
sealed class TransactionBtcNode with _$TransactionBtcNode {
  const factory TransactionBtcNode({
    required String txId,
    // required int version,
    required List<Vin> vin,
    required List<Vout> vout,
    required int blockHeight,
    required int confirmations,
    required bool rbf,
    required int? fees,
    required int size,
    required int vSize,
  }) = _TransactionBtcNode;

  const TransactionBtcNode._();

  /// Подтверждена ли транзакция
  bool get isPending => confirmations == 0;

  /// Из чего строилась транзакция (utxo)
  List<String> get inputUtxoIds => vin.map((e) => e.txId).toList();

  /// Выбрать выходы которые нужно забрать для rbf транзакции:
  /// - не сдача
  /// - не коммент
  /// - не что-то левое вроде мультисигов
  ///
  /// [includeMessage] если true то в выдаче будет и нулевой выход (OP Return)
  /// в виде поля message
  ({List<BitcoinOutput> outputs, String? message})
      onlyTransfersToOutputsOrThrow({
    required BitcoinNetwork network,
    required bool includeMessage,
    required String senderAddress,
  }) {
    final vouts = <Vout>[];
    String? message;

    // Если во входах которые мы тратим нет нашего адреса (входящая транзакция)
    // то ничего не берем отсюда
    if (vin.any((v) => v.isAddress && !v.addresses.contains(senderAddress))) {
      InAppLogger.instance.logWarning(
        'TransactionBtcNode',
        'onlyTransfersToOutputsOrThrow: Input transaction: $txId, skipping',
      );
      return (outputs: [], message: null);
    }

    // Выберем выходы для конвертации
    for (final v in vout) {
      // Не берем комменты
      if (v.valueInSatoshi <= 0 && !includeMessage) continue;
      // Берем только адреса и в списке должен быть только один адрес (не
      // мультисиги)
      if (v.addresses.length != 1) continue;
      // Не берем сдачу и неподтвержденные входы самому себе (например,
      // входящие неподтвержденные транзакции
      if (v.addresses.contains(senderAddress)) continue;
      if (v.isAddress) vouts.add(v);
      // OP_RETURN
      if (!v.isAddress && v.valueInSatoshi == 0 && includeMessage) {
        final regex = RegExp(r'^OP_RETURN \((.*)\)$');
        final match = regex.firstMatch(v.addresses.first);
        if (match != null) message = match.group(1);
      }
    }

    final outputs = vouts
        .map(
          (e) => BitcoinOutput(
            address:
                BitcoinAddress(e.addresses.first, network: network).baseAddress,
            value: BigInt.from(e.valueInSatoshi),
          ),
        )
        .toList();

    return (outputs: outputs, message: message);
  }
}

/// DTO входа Vin
@freezed
sealed class Vin with _$Vin {
  /// DTO входа Vin
  const factory Vin({
    required String txId,
    // required int vout,
    required int sequence,
    required int n,
    required List<String> addresses,
    required bool isAddress,
    required int valueInSatoshi,
  }) = _Vin;
}

/// DTO выхода Vout
@freezed
sealed class Vout with _$Vout {
  /// DTO выхода Vout
  const factory Vout({
    /// DTO входа Vin
    required int valueInSatoshi,
    required int n,
    required String hex,
    required List<String> addresses,
    required bool isAddress,
  }) = _Vout;
}
