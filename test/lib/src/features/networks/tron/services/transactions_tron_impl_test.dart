import 'package:blockchain_utils/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _url = 'https://node.example/trx';
const _from = 'TP8KmXDvKVYg5WVTTyqaNT61Htguw2NJBs';
const _to = 'TNPeeaaFB7K9cmo4uQpcU32zGK8G1NYqeL';

TransactionsServiceTronImpl _service({
  required http.Client client,
  String? Function()? getAuthToken,
}) => TransactionsServiceTronImpl(
  getSigningKey: (_) async => null,
  rpc: TronProvider(
    TronHTTPProvider(url: _url, client: client, getAuthToken: getAuthToken),
  ),
);

TransferParamsTRON _params(BigRational amount) => TransferParamsTRON(
  to: _to,
  from: _from,
  amount: amount,
  tokenWalletType: TokenWalletType.master,
  tokenDecimal: 6,
  tokenContractAddress: null,
);

void main() {
  group('TransactionsServiceTronImpl', () {
    test('requests go through the injected provider with the current '
        'token', () async {
      final requests = <http.Request>[];
      final service = _service(
        client: MockClient((request) async {
          requests.add(request);
          throw http.ClientException('down');
        }),
        getAuthToken: () => 'token',
      );

      await expectLater(
        service.createTransaction(
          params: _params(BigRational.one),
          masterKey: '',
        ),
        throwsA(isA<http.ClientException>()),
      );

      expect(requests.single.url.toString(), startsWith(_url));
      expect(requests.single.headers['Authorization'], 'Bearer token');
    });

    test('THROWS amountIsNotPositive for a zero amount', () async {
      final requests = <http.Request>[];
      final service = _service(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('{}', 200);
        }),
      );

      await expectLater(
        service.createTransaction(
          params: _params(BigRational.zero),
          masterKey: '',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.amountIsNotPositive,
          ),
        ),
      );
      expect(requests, isEmpty);
    });
  });
}
