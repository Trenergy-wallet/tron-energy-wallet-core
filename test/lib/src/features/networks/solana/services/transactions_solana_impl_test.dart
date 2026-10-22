import 'package:blockchain_utils/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

const _url = 'https://node.example/sol';
const _address = '9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM';

/// Node mock: answers with [result], records the requests
MockClient _node(List<http.Request> requests, {String result = '42'}) =>
    MockClient((request) async {
      requests.add(request);
      return http.Response('{"jsonrpc":"2.0","id":1,"result":$result}', 200);
    });

TransactionsServiceSolanaImpl _service({
  required http.Client client,
  String? Function()? getAuthToken,
}) => TransactionsServiceSolanaImpl(
  getSigningKey: (_) async => '',
  isTestnet: true,
  rpc: SolanaProvider(
    SolanaHTTPProvider(url: _url, client: client, getAuthToken: getAuthToken),
  ),
);

void main() {
  group('TransactionsServiceSolanaImpl', () {
    test('requests go through the injected provider, the token is read on '
        'every request', () async {
      final requests = <http.Request>[];
      var token = 'first';
      final service = _service(
        client: _node(requests),
        getAuthToken: () => token,
      );

      final rent = await service.getMinimumBalanceForRentExemption(
        TokenWalletType.master,
      );
      token = 'second';
      await service.getMinimumBalanceForRentExemption(TokenWalletType.master);

      expect(rent, BigInt.from(42));
      expect(requests, hasLength(2));
      expect(requests.first.url.toString(), _url);
      expect(requests[0].headers['Authorization'], 'Bearer first');
      expect(requests[1].headers['Authorization'], 'Bearer second');
    });

    group('accountExists', () {
      test('false for a missing account', () async {
        final service = _service(
          client: _node([], result: '{"context":{"slot":1},"value":null}'),
        );

        expect(await service.accountExists(_address), isFalse);
      });

      test('THROWS ClientException when the node is unavailable', () async {
        final service = _service(
          client: MockClient((_) async => throw http.ClientException('down')),
        );

        await expectLater(
          service.accountExists(_address),
          throwsA(isA<http.ClientException>()),
        );
      });
    });

    test('THROWS amountIsNotPositive for a zero amount', () async {
      final service = _service(client: _node([]));

      await expectLater(
        service.createTransaction(
          params: TransferParamsSOL(
            to: _address,
            from: _address,
            amount: BigRational.zero,
            tokenDecimal: 9,
            tokenWalletType: TokenWalletType.master,
          ),
          masterKey: 'mk',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.amountIsNotPositive,
          ),
        ),
      );
    });
  });
}
