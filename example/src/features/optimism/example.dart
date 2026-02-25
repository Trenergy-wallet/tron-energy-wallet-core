// example purposes
// ignore_for_file: unused_local_variable

import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/erc_20_balance.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

// https://docs.optimism.io/op-mainnet/network-information/connecting-to-op

// Explorer
// https://explorer.optimism.io
// https://testnet-explorer.optimism.io

// Faucet
// https://ethfaucet.com/networks/optimism/optimism-sepolia
// https://faucet.circle.com/

final _rpc = EthereumProvider(
  EthereumHTTPProvider(
    // 'https://mainnet.optimism.io/',
    'https://sepolia.optimism.io/',
    '',
  ),
);

// Optimism Sepolia
const _chainIdTestNet = 11155420;
const _chainIdMainNet = 10;
// ETH decimal: 18
// USDC decimal: 6
// USDC contractAddress:
const _usdcContractAddress = '0x5fd84259d66Cd46123540766Be93DFE6D43130D7';

Future<void> main() async {
  const name = 'OpExample';
  final logger = InAppLogger()..usePrint = true;
  final service = TransactionsServiceOptimismImpl(
    rpc: _rpc,
    getSigningKey: (_) async => 'your-mnemonic',
    logger: logger,
  );

  final walletInfo = await service.initializeWalletAndGetInfo(
    masterKey: '',
  );

  logger.logInfoMessage(name, 'Main address: ${walletInfo.address}');

  final bal = await _rpc.request(
    EthereumRequestGetBalance(address: walletInfo.address),
  );
  logger.logInfoMessage(name, 'Balance: $bal');

  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      _usdcContractAddress,
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage(name, 'TokenBalance: $tokenBalance');

  // // USDC Transfer
  // final tx = await service.createTransaction(
  //   params: TransferParamsETH(
  //     to: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
  //     from: walletInfo.address,
  //     amount: BigRational.parseDecimal('0.001'),
  //     chainId: _chainIdTestNet,
  //     supportsEIP1559: true, // true | false
  //     tokenDecimal: 6, // USDC
  //     tokenContractAddress: _usdcContractAddress,
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
      supportsEIP1559: true,
      // true | false
      tokenDecimal: 18,
      tokenWalletType: TokenWalletType.master,
      tokenName: 'ETH',
      // message: 'hi',
    ),
    masterKey: '',
  );
  logger.logInfoMessage(name, 'TX: $tx');
  // final sentTx = await _rpc.request(
  //   EthereumRequestSendRawTransaction(transaction: tx),
  // );
  // logger.logInfoMessage(name, 'SENT: $sentTx');
}
