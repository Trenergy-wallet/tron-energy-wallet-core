import 'package:blockchain_utils/blockchain_utils.dart' show BigRational;
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

void main() {
  group('TransferParamsBTC', () {
    test('defaults to bitcoin', () {
      final params = TransferParamsBTC(
        to: '',
        from: '',
        amount: BigRational.one,
        tokenWalletType: TokenWalletType.master,
        feeType: FeeType.optimal,
      );
      expect(params.appBlockchain, AppBlockchain.bitcoin);
    });
  });
}
