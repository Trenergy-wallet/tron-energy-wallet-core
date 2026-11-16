import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'data/repo/ltc_blockbook_repo_impl.dart';

const _name = 'ltcExample';

/// Mainnet sends real funds
const _useTestnet = true;

/// Put your mnemonic here and never commit it
const _mnemonic = '_mnemonic';

/// NOWNodes API key, never commit it
const _nowNodesApiKey = '_nowNodesApiKey';

// Explorer: https://litecoinspace.org/testnet
Future<void> main() async {
  final logger = InAppLogger()..usePrint = true;
  // Blockbook as in the wallet. Without an API key use
  // `LTCNodeRepoImpl(isTestnet: _useTestnet)` over litecoinspace.org
  final nodeRepo = LTCBlockbookRepoImpl.nowNodes(
    apiKey: _nowNodesApiKey,
    isTestnet: _useTestnet,
  );

  // The same service as for Bitcoin: Litecoin differs only by the blockchain
  // and the network (native SegWit address instead of Taproot)
  final ltcService = TransactionsServiceBTCImpl(
    appBlockchain: AppBlockchain.litecoin,
    network: _useTestnet ? LitecoinNetwork.testnet : LitecoinNetwork.mainnet,
    btcNodeRepo: nodeRepo,
    estimateFee: nodeRepo.getEstimateFee,
    logger: logger,
    getSigningKey: (_) async => _mnemonic,
  );

  final walletInfo = await ltcService.initializeWalletAndGetInfo(
    masterKey: '',
  );
  logger.logInfoMessage(_name, 'Address: ${walletInfo.address}');

  final tx = await ltcService.createTransaction(
    params: TransferParamsBTC(
      appBlockchain: AppBlockchain.litecoin,
      // Sending to yourself, put any ltc1q... (tltc1q... on testnet) address
      to: walletInfo.address,
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.0001'),
      tokenWalletType: TokenWalletType.master,
      feeType: FeeType.optimal,
      // message: '',
    ),
    masterKey: '',
  );
  logger.logInfoMessage(_name, 'TX: $tx');

  final txId = await nodeRepo.broadcast(tx);
  logger.logInfoMessage(_name, 'SENT ID: $txId');
}
