import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

BigRational _r(String value) => BigRational.parseDecimal(value);

void main() {
  group('UnitsConverter.tokenToUnits', () {
    test('shifts the amount by the token decimals', () {
      final cases = <({String amount, int decimals, BigInt result})>[
        (
          amount: '1.23',
          decimals: 18,
          result: BigInt.parse('1230000000000000000'),
        ),
        (
          amount: '1',
          decimals: 18,
          result: BigInt.parse('1000000000000000000'),
        ),
        (amount: '2', decimals: 6, result: BigInt.from(2000000)),
        (amount: '0.000001', decimals: 6, result: BigInt.one),
        (amount: '123', decimals: 0, result: BigInt.from(123)),
        (amount: '0', decimals: 18, result: BigInt.zero),
      ];
      for (final e in cases) {
        expect(
          UnitsConverter.tokenToUnits(
            amount: _r(e.amount),
            decimals: e.decimals,
          ),
          e.result,
          reason: '${e.amount} with ${e.decimals} decimals',
        );
      }
    });

    test('keeps the sign of a negative amount', () {
      expect(
        UnitsConverter.tokenToUnits(amount: _r('-1.5'), decimals: 2),
        BigInt.from(-150),
      );
    });

    test('drops the digits below the smallest unit instead of rounding', () {
      // 0.1234567 does not fit into 6 decimals: the tail is cut off, so the
      // conversion never produces more units than the user actually sends
      expect(
        UnitsConverter.tokenToUnits(amount: _r('0.1234567'), decimals: 6),
        BigInt.from(123456),
      );
      expect(
        UnitsConverter.tokenToUnits(amount: _r('0.9999999'), decimals: 6),
        BigInt.from(999999),
      );
      expect(
        UnitsConverter.tokenToUnits(amount: _r('-0.9999999'), decimals: 6),
        BigInt.from(-999999),
      );
    });

    test('handles amounts far above the int range', () {
      expect(
        UnitsConverter.tokenToUnits(
          amount: _r('123456789012345.678901234567890123'),
          decimals: 18,
        ),
        BigInt.parse('123456789012345678901234567890123'),
      );
    });
  });

  group('UnitsConverter.unitsToTokens', () {
    test('shifts the units back by the token decimals', () {
      expect(
        UnitsConverter.unitsToTokens(units: BigInt.from(2000000), decimals: 6),
        _r('2'),
      );
      expect(
        UnitsConverter.unitsToTokens(units: BigInt.from(2100000), decimals: 6),
        _r('2.1'),
      );
      expect(
        UnitsConverter.unitsToTokens(units: BigInt.one, decimals: 18),
        _r('0.000000000000000001'),
      );
      expect(
        UnitsConverter.unitsToTokens(units: BigInt.from(123), decimals: 0),
        _r('123'),
      );
      expect(
        UnitsConverter.unitsToTokens(units: BigInt.zero, decimals: 18),
        BigRational.zero,
      );
    });

    test('keeps the sign of negative units', () {
      expect(
        UnitsConverter.unitsToTokens(units: BigInt.from(-150), decimals: 2),
        _r('-1.5'),
      );
    });

    test('is exact: no precision is lost on a full round trip', () {
      const decimals = 18;
      final amounts = ['0.000000000000000001', '1.23', '0.1', '987654321.5'];
      for (final amount in amounts) {
        final units = UnitsConverter.tokenToUnits(
          amount: _r(amount),
          decimals: decimals,
        );
        expect(
          UnitsConverter.unitsToTokens(units: units, decimals: decimals),
          _r(amount),
          reason: amount,
        );
      }
    });
  });
}
