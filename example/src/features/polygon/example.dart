import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/erc_20_balance.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

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

// Polygon Amoy
const _chainIdTestNet = 80002;
// ETH decimal: 18
// USDC decimal: 6
// USDC contractAddress:
const _usdcMockContractAddress = '0x8B0180f2101c8260d49339abfEe87927412494B4';
const _usdcCircleTestnetContractAddress =
    '0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582';

Future<void> main() async {
  final logger = InAppLogger()..usePrint = true;
  final service = TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.polygon,
    rpc: _rpc,
    logger: logger,
    getSigningKey: (_) async => 'your mnemonic',
  );

  final walletInfo = await service.initializeWalletAndGetInfo(
    masterKey: '',
  );

  logger.logInfoMessage('polExample', 'Main address: ${walletInfo.address}');

  final bal = await _rpc.request(
    EthereumRequestGetBalance(address: walletInfo.address),
  );
  logger.logInfoMessage('polExample', 'Balance: $bal');
  // final gasPrice = await _rpc.request(
  //   EthereumRequestGetGasPrice(),
  // );
  // logger.logInfoMessage('polExample', 'Gas Price: $gasPrice');

  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      _usdcMockContractAddress,
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage('polExample', 'tokenBalance: $tokenBalance');
  // // USDC Transfer
  // final tx = await service.createTransaction(
  //   params: TransferParamsETH(
  //     to: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
  //     from: walletInfo.address,
  //     amount: BigRational.parseDecimal('0.001'),
  //     chainId: _chainIdTestNet,
  //     supportsEIP1559: true, // true | false
  //     tokenDecimal: 6, // USDC
  //     tokenContractAddress: _usdcMockContractAddress,
  //     tokenWalletType: TokenWalletType.child,
  //     tokenName: 'USDC',
  //   ),
  //   masterKey: '',
  // );

  // ETH transfer
  final tx = await service.createTransaction(
    params: TransferParamsETH(
      to: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.001'),
      chainId: _chainIdTestNet,
      // true | false
      supportsEIP1559: true,
      tokenDecimal: 18,
      tokenWalletType: TokenWalletType.master,
      tokenName: 'POL',
      // message: 'hi',
    ),
    masterKey: '',
  );

  logger.logInfoMessage('polExample', 'TX: $tx');
  final sentTx = await _rpc.request(
    EthereumRequestSendRawTransaction(transaction: tx),
  );
  logger.logInfoMessage('polExample', 'SENT: $sentTx');
}
