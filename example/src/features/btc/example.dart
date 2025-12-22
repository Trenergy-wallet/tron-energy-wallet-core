import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../../common/setup_account.dart';
import '../../data/repo/local_repo_core_impl.dart';
import 'data/repo/btc_node_repo_impl.dart';
import 'domain/asset.dart';

Future<void> main() async {
  await setupAccount(
    mnemonic: 'mnemonic',
  );

  final localRepo = LocalRepoImpl();
  final btcNodeRepo = BTCNodeRepoImpl(
    apiKey: 'api-key',
    isTestnet: true,
    baseUrl: 'https://rpc.ankr.com/',
  );
  final logger = InAppLogger();

  final btcService = TransactionsServiceBTCImpl(
    localRepo: localRepo,
    postTransaction: btcNodeRepo.postTransaction,
    btcNodeRepo: btcNodeRepo,
    estimateFee: btcNodeRepo.getEstimateFee,
    network: BitcoinNetwork.signet,
  );

  final walletInfo = await btcService.tryInitializeWalletAndGetInfoOrThrow(
    masterKey: '',
  );
  logger.logInfoMessage('btcExample', 'Address: ${walletInfo.address}');
  final btcAsset = btcAssetExample(walletInfo.address);
  final tx = await btcService.createTransactionOrThrow(
    toAddress: 'tb1p8kxn49u3saux772xy33f8295ma30zrzp8egywvxlxu6860u9ekaqx39n2y',
    amount: BigRational.parseDecimal('0.0001'),
    asset: btcAsset,
    masterKey: '',
    feeType: FeeType.optimal,
  );
  logger.logInfoMessage('btcExample', 'TX: $tx');
  final sentTx = await btcService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('btcExample', 'SENT: $sentTx');
}
