part of 'transactions_eth_impl.dart';

/// Transactions Service
///
/// Provides services for creating and signing BASE transactions
class TransactionsServiceBaseImpl extends TransactionsServiceEthereumImpl {
  /// Provides services for creating and signing BASE transactions
  TransactionsServiceBaseImpl({
    required super.getSigningKey,
    required super.rpc,
    super.logger,
  }) : super(appBlockchain: AppBlockchain.base);

  @override
  BigInt applyEIP1559FeeBufferMultiplier(BigInt value) =>
      value * BigInt.from(3) ~/ BigInt.from(2);

  @override
  BigInt applyLegacyFeeBufferMultiplier(BigInt value) =>
      value * BigInt.from(3) ~/ BigInt.from(2);

  @override
  Future<BigInt> Function(ETHTransaction transaction)? get _onEstimateL1Fee =>
      (tx) async => rpc.request(
        RPCOpGetL1Fee(
          tx.serialized,
          '0x420000000000000000000000000000000000000F',
        ),
      );
}
