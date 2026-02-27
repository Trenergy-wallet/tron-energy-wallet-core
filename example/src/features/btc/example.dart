import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'data/api/btc_explorer_service.dart';
import 'data/repo/btc_node_repo_impl.dart';

Future<void> main() async {
  final btcNodeRepo = BTCNodeRepoImpl(
    apiKey: 'api-key',
    isTestnet: true,
    baseUrl: 'https://rpc.ankr.com/',
  );
  final logger = InAppLogger()..usePrint = true;

  final btcService = TransactionsServiceBTCImpl(
    btcNodeRepo: btcNodeRepo,
    estimateFee: btcNodeRepo.getEstimateFee,
    network: BitcoinNetwork.signet,
    logger: logger,
    getSigningKey: (_) async => 'mnemonic',
  );

  final walletInfo = await btcService.initializeWalletAndGetInfo(
    masterKey: '',
  );
  logger.logInfoMessage('btcExample', 'Address: ${walletInfo.address}');
  final tx = await btcService.createTransaction(
    params: TransferParamsBTC(
      to: 'tb1p8kxn49u3saux772xy33f8295ma30zrzp8egywvxlxu6860u9ekaqx39n2y',
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.0001'),
      tokenWalletType: TokenWalletType.master,
      feeType: FeeType.optimal,
      // message: '',
    ),
    masterKey: '',
  );
  logger.logInfoMessage('btcExample', 'TX: $tx');
  final service = BitcoinApiService();
  final api = ApiProvider.fromMempool(
    BitcoinNetwork.signet, // BitcoinNetwork.mainnet,
    service,
  );
  final txId = await api.sendRawTransaction(tx);
  logger.logInfoMessage('btcExample', 'SENT ID: $txId');
}
