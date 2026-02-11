part of 'transactions_eth_impl.cg.dart';

/// Transactions Service
///
/// Provides services for creating and signing OPTIMISM transactions
class TransactionsServiceOptimismImpl extends TransactionsServiceEthereumImpl {
  /// Provides services for creating and signing OPTIMISM transactions
  TransactionsServiceOptimismImpl({
    required super.getSigningKey,
    super.getAuthToken,
    super.rpc,
    super.apiUri,
    super.logger,
  }) : super(appBlockchain: AppBlockchain.optimism);

  @override
  BigInt applyBufferMultiplier(BigInt value) =>
      value * BigInt.from(3) ~/ BigInt.from(2);

  @override
  Future<BigInt> Function(ETHTransaction transaction)? get _onEstimateL1Fee =>
      (tx) async => _ethereumProvider.request(
        RPCOpGetL1Fee(tx.serialized),
      );
}
