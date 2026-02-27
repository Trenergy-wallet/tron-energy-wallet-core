import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/erc_20_balance.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

final _rpc = EthereumProvider(
  EthereumHTTPProvider(
    'https://data-seed-prebsc-1-s1.binance.org:8545/',
    '',
  ),
);

// BNB
const _chainIdTestNet = 97;
// ETH decimal: 18
// USDT decimal: 18
// USDT contractAddress:
const _usdtContractAddress = '0x337610d27c682e347c9cd60bd4b3b107c9d34ddd';

Future<void> main() async {
  final logger = InAppLogger()..usePrint = true;
  final service = TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.bsc,
    rpc: _rpc,
    logger: logger,
    getSigningKey: (_) async => 'your-mnemonic',
  );

  final walletInfo = await service.initializeWalletAndGetInfo(
    masterKey: '',
  );

  logger.logInfoMessage('bnbExample', 'Main address: ${walletInfo.address}');

  final bal = await _rpc.request(
    EthereumRequestGetBalance(address: walletInfo.address),
  );
  logger.logInfoMessage('bnbExample', 'Balance: $bal');

  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      _usdtContractAddress,
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage('bnbExample', 'tokenBalance: $tokenBalance');

  // // USDT Transfer
  // final tx = await service.createTransaction(
  //   params: TransferParamsETH(
  //     to: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
  //     from: walletInfo.address,
  //     amount: BigRational.parseDecimal('0.001'),
  //     chainId: _chainIdTestNet,
  //     supportsEIP1559: false, // false only!
  //     tokenDecimal: 18, // USDT
  //     tokenContractAddress: _usdtContractAddress,
  //     tokenWalletType: TokenWalletType.child,
  //     tokenName: 'USDT',
  //   ),
  //   masterKey: '',
  // );

  // BNB transfer
  final tx = await service.createTransaction(
    params: TransferParamsETH(
      to: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.001'),
      chainId: _chainIdTestNet,
      supportsEIP1559: false,
      // false only!
      tokenDecimal: 18,
      // ETH
      tokenWalletType: TokenWalletType.master,
      tokenName: 'BNB',
      // message: 'hi',
    ),
    masterKey: '',
  );

  logger.logInfoMessage('bnbExample', 'TX: $tx');
  final sentTx = await _rpc.request(
    EthereumRequestSendRawTransaction(transaction: tx),
  );
  logger.logInfoMessage('bnbExample', 'SENT: $sentTx');
}
