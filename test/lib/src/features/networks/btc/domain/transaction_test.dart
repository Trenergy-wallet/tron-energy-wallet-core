import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Our wallet address (m/84'/2'/0'/0/0 of the public "abandon...about" vector)
const _sender = 'ltc1qjmxnz78nmc8nq77wuxh25n2es7rzm5c2rkk4wh';

String _segwit(int seed) => ECPrivate.fromBytes(
  List.filled(32, seed),
).getPublic().toSegwitAddress().toAddress(LitecoinNetwork.mainnet);

/// Litecoin network supports Taproot, bitcoin_base does not
String _taproot(int seed) =>
    ECPrivate.fromBytes(
          List.filled(32, seed),
        )
        .getPublic()
        .toTaprootAddress()
        .toAddress(BitcoinNetwork.mainnet)
        .replaceFirst('bc1p', 'ltc1p');

Vout _vout(int n, String address, {int value = 10000}) => Vout(
  valueInSatoshi: value,
  n: n,
  hex: '',
  addresses: [address],
  isAddress: true,
);

TransactionBtcNode _tx(List<Vout> vout) => TransactionBtcNode(
  txId: 'bb' * 32,
  vin: [
    Vin(
      txId: 'aa' * 32,
      sequence: 0xfffffffd,
      n: 0,
      addresses: [_sender],
      isAddress: true,
      valueInSatoshi: 100000,
    ),
  ],
  vout: vout,
  blockHeight: CoreConsts.invalidIntValue,
  confirmations: 0,
  rbf: true,
  fees: 1000,
  size: 222,
  vSize: 141,
);

void main() {
  group('TransactionBtcNode.onlyTransfersToOutputsOrThrow', () {
    test('litecoin: takes the transfer, skips the change', () {
      final recipient = _segwit(1);
      final res =
          _tx([
            _vout(0, recipient),
            _vout(1, _sender),
          ]).onlyTransfersToOutputsOrThrow(
            network: LitecoinNetwork.mainnet,
            includeMessage: false,
            senderAddress: _sender,
          );
      expect(res.outputs, hasLength(1));
      expect(
        res.outputs.single.address.toAddress(LitecoinNetwork.mainnet),
        recipient,
      );
      expect(res.outputs.single.value, BigInt.from(10000));
    });

    test('THROWS AppException on an output bitcoin_base cannot build', () {
      expect(
        () => _tx([_vout(0, _taproot(2))]).onlyTransfersToOutputsOrThrow(
          network: LitecoinNetwork.mainnet,
          includeMessage: false,
          senderAddress: _sender,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.unableToCreateTransaction,
          ),
        ),
      );
    });
  });
}
