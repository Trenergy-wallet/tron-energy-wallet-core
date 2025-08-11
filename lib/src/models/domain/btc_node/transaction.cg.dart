import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

part 'gen/transaction.cg.f.dart';

/// Model for querying the node for transaction information
@freezed
sealed class TransactionBtcNode with _$TransactionBtcNode {
  const factory TransactionBtcNode({
    required String txId,
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

  /// Whether the transaction is confirmed
  bool get isPending => confirmations == 0;

  /// What the transaction was built from (UTXO)
  List<String> get inputUtxoIds => vin.map((e) => e.txId).toList();

  /// Select outputs to use for the RBF transaction:
  /// - not change
  /// - not comment
  /// - not something unrelated like multisigs
  ///
  /// [includeMessage] if true, the output will include the zero output
  /// (OP Return) as a message field
  ({List<BitcoinOutput> outputs, String? message})
  onlyTransfersToOutputsOrThrow({
    required BitcoinNetwork network,
    required bool includeMessage,
    required String senderAddress,
  }) {
    final vouts = <Vout>[];
    String? message;

    // If the inputs we are spending don’t include our address
    // (incoming transaction) then we take nothing from here
    if (vin.any((v) => v.isAddress && !v.addresses.contains(senderAddress))) {
      InAppLogger.instance.logWarning(
        'TransactionBtcNode',
        'onlyTransfersToOutputsOrThrow: Input transaction: $txId, skipping',
      );
      return (outputs: [], message: null);
    }

    // Select outputs for conversion
    for (final v in vout) {
      // Do not take comments
      if (v.valueInSatoshi <= 0 && !includeMessage) continue;
      // Take only addresses, and the list must contain only one address
      // (no multisigs)
      if (v.addresses.length != 1) continue;
      // Do not take change and unconfirmed inputs to self (e.g.,
      // incoming unconfirmed transactions)
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
            address: BitcoinAddress(
              e.addresses.first,
              network: network,
            ).baseAddress,
            value: BigInt.from(e.valueInSatoshi),
          ),
        )
        .toList();

    return (outputs: outputs, message: message);
  }
}

/// DTO of input Vin
@freezed
sealed class Vin with _$Vin {
  /// DTO of input Vin
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

/// DTO of output Vout
@freezed
sealed class Vout with _$Vout {
  /// DTO of output Vout
  const factory Vout({
    required int valueInSatoshi,
    required int n,
    required String hex,
    required List<String> addresses,
    required bool isAddress,
  }) = _Vout;
}
