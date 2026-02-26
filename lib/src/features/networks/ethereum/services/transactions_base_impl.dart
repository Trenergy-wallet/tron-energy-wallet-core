part of 'transactions_eth_impl.dart';

/// Transactions Service
///
/// Provides services for creating and signing BASE transactions
class TransactionsServiceBaseImpl extends TransactionsServiceEthereumImpl {
  /// Provides services for creating and signing BASE transactions
  TransactionsServiceBaseImpl({
    required super.getSigningKey,
    super.getAuthToken,
    super.rpc,
    super.apiUri,
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
      (tx) async => _ethereumProvider.request(
        RPCOpGetL1Fee(
          tx.serialized,
          '0x420000000000000000000000000000000000000F',
        ),
      );
}
