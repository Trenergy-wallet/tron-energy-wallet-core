import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

void main() {
  group('AppBlockchain.litecoin', () {
    test('is parsed from the backend slug', () {
      expect(AppBlockchain.fromJson('litecoin'), AppBlockchain.litecoin);
      expect(AppBlockchain.litecoin.toJson(), 'litecoin');
      expect(AppBlockchain.litecoin.mainTokenName, 'LTC');
    });
  });

  group('AppBlockchain.isUtxo', () {
    test('only for bitcoin and litecoin', () {
      expect(
        AppBlockchain.values.where((e) => e.isUtxo),
        [AppBlockchain.bitcoin, AppBlockchain.litecoin],
      );
    });
  });
}
