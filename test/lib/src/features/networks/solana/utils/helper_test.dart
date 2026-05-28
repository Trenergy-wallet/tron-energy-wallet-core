import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tron_energy_wallet_core/src/features/networks/networks.dart';

void main() {
  group('SolanaHelper', () {
    test('lamportsToSol', () {
      expect(SolanaHelper.lamportsToSol(5000).toString(), equals('0.000005'));
      expect(SolanaHelper.lamportsToSol(0).toString(), equals('0'));
      expect(
        SolanaHelper.lamportsToSol(9999999999).toString(),
        equals('9.999999999'),
      );
    });
  });
}
