import 'package:on_chain/ethereum/src/rpc/methds/send_raw_transaction.dart';
import 'package:on_chain/ethereum/src/rpc/provider/provider.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../../common/setup_account.dart';
import '../../data/repo/local_repo_core_impl.dart';
import 'domain/asset.dart';

final _rpc = EthereumProvider(
  EthereumHTTPProvider(
    'https://rpc.ankr.com/eth_sepolia/',
    'your-api-token',
  ),
);

Future<void> main() async {
  await setupAccount(
    mnemonic: 'your-mnemonic',
  );
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();
  final ethService = TransactionsServiceEthereumImpl(
    localRepo: localRepo,
    postTransaction: postTransactionTron,
    rpc: _rpc,
  );

  final walletInfo = await ethService.tryInitializeWalletAndGetInfoOrThrow(
    masterKey: '',
  );

  logger.logInfoMessage('ethExample', 'Main address: ${walletInfo.address}');

  final asset = ethAssetExample(
    address: walletInfo.address,
    supportsEIP1559: true,
  );

  // Example asset for ERC20 token transfer
  // final asset = ethERC20AssetExample(
  //   address: walletInfo.address,
  //   supportsEIP1559: true,
  // );

  final tx = await ethService.createTransactionOrThrow(
    toAddress: '0xB191c75e9401205A578B7caD7cBEc160B88Db558',
    amount: 0.00006,
    asset: asset,
    masterKey: '',
    message: 'hello example',
  );
  logger.logInfoMessage('ethExample', 'TX: $tx');
  final sentTx = await ethService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('ethExample', 'SENT: $sentTx');
}

Future<Either<AppExceptionWithCode, TransactionInfoData>> postTransactionTron({
  required AppBlockchain appBlockchain,
  required String tx,
  String? txFee,
}) async {
  try {
    final res = await _rpc.request(
      EthereumRequestSendRawTransaction(transaction: tx),
    );
    return Right(
      TransactionInfoData(
        txId: res,
        linkToBlockchain: 'https://sepolia.etherscan.io/tx/$res',
      ),
    );
  } on Exception catch (e) {
    return Left(AppException(message: e.toString()));
  }
}
