import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

void main() {
  group('Fees.feeForType', () {
    const fees = Fees(fastestFee: 30, halfHourFee: 20, economyFee: 10);

    test('maps every Bitcoin fee type to its value', () {
      expect(fees.feeForType(FeeType.fast), equals(30));
      expect(fees.feeForType(FeeType.optimal), equals(20));
      expect(fees.feeForType(FeeType.economy), equals(10));
    });

    test('THROWS ArgumentError for gasfree (not applicable to Bitcoin)', () {
      expect(() => fees.feeForType(FeeType.gasFree), throwsArgumentError);
    });
  });

  group('FeeType', () {
    test('isGasfree is true only for gasfree', () {
      expect(FeeType.gasFree.isGasFree, isTrue);
      expect(FeeType.economy.isGasFree, isFalse);
      expect(FeeType.optimal.isGasFree, isFalse);
      expect(FeeType.fast.isGasFree, isFalse);
    });
  });
}
