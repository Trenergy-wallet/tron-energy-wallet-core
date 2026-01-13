import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/erc_20_balance.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import '../../common/setup_account.dart';
import '../../data/repo/local_repo_core_impl.dart';
import 'domain/asset.dart';

final _rpc = EthereumProvider(
  EthereumHTTPProvider(
    // 'https://arb1.arbitrum.io/rpc/',
    'https://sepolia-rollup.arbitrum.io/rpc/',
    '',
  ),
);

Future<void> main() async {
  await setupAccount(mnemonic: 'your-mnemonic');
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();
  final ethService = TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.arbitrum,
    localRepo: localRepo,
    postTransaction: _postTransactionARB,
    rpc: _rpc,
  );

  final walletInfo = await ethService.tryInitializeWalletAndGetInfoOrThrow(
    masterKey: '',
  );

  logger.logInfoMessage('arbExample', 'Main address: ${walletInfo.address}');

  // final asset = arbAssetExample(
  //   address: walletInfo.address,
  // );

  final bal = await _rpc.request(
    EthereumRequestGetBalance(address: walletInfo.address),
  );
  logger.logInfoMessage('arbExample', 'Balance: $bal');

  // final gasPrice = await _rpc.request(
  //   EthereumRequestGetGasPrice(),
  // );
  // logger.logInfoMessage('arbExample', 'Gas Price: $gasPrice');

  // Example asset for ERC20 token transfer
  final assetBEP20 = arbBEP20AssetExample(address: walletInfo.address);
  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      assetBEP20.token.contractAddress,
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage('arbExample', 'tokenBalance: $tokenBalance');

  final tx = await ethService.createTransactionOrThrow(
    toAddress: '0x077B122c047a58174f1e8B011C8A6F768C0AC190',
    amount: BigRational.parseDecimal('0.001'),
    asset: assetBEP20,
    masterKey: '',
    // message: 'hi',
  );
  logger.logInfoMessage('arbExample', 'TX: $tx');
  final sentTx = await ethService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('arbExample', 'SENT: $sentTx');
}

Future<Either<AppExceptionWithCode, TransactionInfoData>> _postTransactionARB({
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
        linkToBlockchain: 'https://sepolia.arbiscan.io/tx/$res',
      ),
    );
  } on Exception catch (e) {
    return Left(AppException(message: e.toString()));
  }
}
