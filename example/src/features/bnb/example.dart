import 'package:blockchain_utils/blockchain_utils.dart';
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
    'https://data-seed-prebsc-1-s1.binance.org:8545/',
    '',
  ),
);

Future<void> main() async {
  await setupAccount(
    mnemonic: 'your-mnemonic',
  );
  final localRepo = LocalRepoImpl();
  final logger = InAppLogger();
  final ethService = TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.bsc,
    localRepo: localRepo,
    postTransaction: _postTransactionBSC,
    rpc: _rpc,
  );

  final walletInfo = await ethService.tryInitializeWalletAndGetInfoOrThrow(
    masterKey: '',
  );

  logger.logInfoMessage('bnbExample', 'Main address: ${walletInfo.address}');

  // final asset = bnbAssetExample(
  //   address: walletInfo.address,
  // );

  final bal = await _rpc.request(
    EthereumRequestGetBalance(address: walletInfo.address),
  );
  logger.logInfoMessage('bnbExample', 'Balance: $bal');

  // Example asset for ERC20 token transfer
  final assetBEP20 = bscBEP20AssetExample(address: walletInfo.address);
  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      assetBEP20.token.contractAddress,
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage('bnbExample', 'tokenBalance: $tokenBalance');

  // final feeEstimate = await ethService.tryEstimateFee(
  //   addressToSend: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
  //   asset: asset,
  //   message: 'hi',
  // );
  //
  final tx = await ethService.createTransactionOrThrow(
    toAddress: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
    amount: BigRational.parseDecimal('0.01'),
    asset: assetBEP20,
    masterKey: '',
    // message: 'hi',
  );
  logger.logInfoMessage('bnbExample', 'TX: $tx');
  final sentTx = await ethService.postTransactionOrThrow(tx: tx);
  logger.logInfoMessage('bnbExample', 'SENT: $sentTx');
}

Future<Either<AppExceptionWithCode, TransactionInfoData>> _postTransactionBSC({
  required AppBlockchain appBlockchain,
  required String tx,
  String? transactionType,
  int? operationId,
  String? txFee,
}) async {
  try {
    final res = await _rpc.request(
      EthereumRequestSendRawTransaction(transaction: tx),
    );
    return Right(
      TransactionInfoData(
        txId: res,
        linkToBlockchain: 'https://testnet.bsctrace.com/tx/$res',
      ),
    );
  } on Exception catch (e) {
    return Left(AppException(message: e.toString()));
  }
}
