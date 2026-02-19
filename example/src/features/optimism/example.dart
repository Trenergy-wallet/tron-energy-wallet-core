// example purposes
// ignore_for_file: unused_local_variable

import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/erc_20_balance.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

import 'domain/asset.dart';

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

Future<void> main() async {
  const name = 'OpExample';
  final logger = InAppLogger()..usePrint = true;
  final opService = TransactionsServiceOptimismImpl(
    rpc: _rpc,
    getSigningKey: (_) async => 'your-mnemonic',
    logger: logger,
  );

  final walletInfo = await opService.initializeWalletAndGetInfo(
    masterKey: '',
  );

  logger.logInfoMessage(name, 'Main address: ${walletInfo.address}');

  final asset = opEthAssetExample(
    address: walletInfo.address,
    supportsEIP1559: true,
    isMainnet: false,
  );

  final bal = await _rpc.request(
    EthereumRequestGetBalance(address: walletInfo.address),
  );
  logger.logInfoMessage(name, 'Balance: $bal');

  // Example asset for ERC20 token transfer
  final assetERC20 = opUSDCTestnetAssetExample(
    address: walletInfo.address,
    supportsEIP1559: true,
  );

  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      assetERC20.token.contractAddress,
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage(name, 'TokenBalance: $tokenBalance');

  // final feeEstimate = await opService.tryEstimateFee(
  //   addressToSend: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
  //   asset: assetERC20,
  //   amount: '0.01',
  //   // message: 'hi',
  // );
  // logger.logInfoMessage(name, 'Est fee: $feeEstimate');

  final tx = await opService.createTransaction(
    toAddress: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
    amount: BigRational.parseDecimal('0.001'),
    asset: assetERC20,
    masterKey: '',
    // message: 'hi',
  );
  logger.logInfoMessage(name, 'TX: $tx');
  // final sentTx = await _rpc.request(
  //   EthereumRequestSendRawTransaction(transaction: tx),
  // );
  // logger.logInfoMessage(name, 'SENT: $sentTx');
}
