import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/erc_20_balance.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'domain/asset.dart';

// Network details
// https://docs.polygon.technology/pos/reference/rpc-endpoints/

// Explorer
// https://amoy.polygonscan.com/

// Faucet
// https://faucet.polygon.technology/

final _rpc = EthereumProvider(
  EthereumHTTPProvider(
    // 'https://polygon-rpc.com/',
    'https://rpc-amoy.polygon.technology/',
    '',
  ),
);

Future<void> main() async {
  final logger = InAppLogger()..usePrint = true;
  final ethService = TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.polygon,
    rpc: _rpc,
    logger: logger,
    getSigningKey: (_) async => 'your mnemonic',
  );

  final walletInfo = await ethService.initializeWalletAndGetInfo(
    masterKey: '',
  );

  logger.logInfoMessage('polExample', 'Main address: ${walletInfo.address}');
  final asset = polTestnetAmoyAssetExample(
    address: walletInfo.address,
  );

  final bal = await _rpc.request(
    EthereumRequestGetBalance(address: walletInfo.address),
  );
  logger.logInfoMessage('polExample', 'Balance: $bal');
  // final gasPrice = await _rpc.request(
  //   EthereumRequestGetGasPrice(),
  // );
  // logger.logInfoMessage('polExample', 'Gas Price: $gasPrice');

  // Example asset for ERC20 token transfer
  final assetERC20 = polUSDCMockTestnetAmoyAssetExample(
    address: walletInfo.address,
  );
  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      assetERC20.token.contractAddress,
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage('polExample', 'tokenBalance: $tokenBalance');

  final tx = await ethService.createTransaction(
    toAddress: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
    amount: BigRational.parseDecimal('0.002'),
    asset: asset,
    masterKey: '',
    // message: 'hi',
  );
  logger.logInfoMessage('polExample', 'TX: $tx');
  final sentTx = await _rpc.request(
    EthereumRequestSendRawTransaction(transaction: tx),
  );
  logger.logInfoMessage('polExample', 'SENT: $sentTx');
}
