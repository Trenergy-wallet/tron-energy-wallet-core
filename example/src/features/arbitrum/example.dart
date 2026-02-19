import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/erc_20_balance.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'domain/asset.dart';

final _rpc = EthereumProvider(
  EthereumHTTPProvider(
    // 'https://arb1.arbitrum.io/rpc/',
    'https://sepolia-rollup.arbitrum.io/rpc/',
    '',
  ),
);

Future<void> main() async {
  final logger = InAppLogger()..usePrint = true;
  final ethService = TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.arbitrum,
    rpc: _rpc,
    logger: logger,
    getSigningKey: (_) async => 'your-mnemonic',
  );

  final walletInfo = await ethService.initializeWalletAndGetInfo(
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
  final assetERC20 = arbERC20AssetExample(address: walletInfo.address);
  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      assetERC20.token.contractAddress,
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage('arbExample', 'tokenBalance: $tokenBalance');

  final tx = await ethService.createTransaction(
    toAddress: '0x077B122c047a58174f1e8B011C8A6F768C0AC190',
    amount: BigRational.parseDecimal('0.001'),
    asset: assetERC20,
    masterKey: '',
    // message: 'hi',
  );
  logger.logInfoMessage('arbExample', 'TX: $tx');
  final sentTx = await _rpc.request(
    EthereumRequestSendRawTransaction(transaction: tx),
  );
  logger.logInfoMessage('arbExample', 'SENT: $sentTx');
}
