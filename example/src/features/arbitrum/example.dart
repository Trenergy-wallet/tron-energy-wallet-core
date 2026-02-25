import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/api/requests/erc_20_balance.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

// Arbitrum Sepolia
const _chainId = 421614;
// ETH decimal: 18
// USDC decimal: 6
// USDC contractAddress:
const _usdcContractAddress = '0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d';

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

  final bal = await _rpc.request(
    EthereumRequestGetBalance(address: walletInfo.address),
  );
  logger.logInfoMessage('arbExample', 'Balance: $bal');

  // final gasPrice = await _rpc.request(
  //   EthereumRequestGetGasPrice(),
  // );
  // logger.logInfoMessage('arbExample', 'Gas Price: $gasPrice');

  final tokenBalance = await _rpc.request(
    RPCERC20TokenBalance(
      '0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d',
      SolidityAddress(walletInfo.address),
    ),
  );
  logger.logInfoMessage('arbExample', 'tokenBalance: $tokenBalance');

  // USDC Transfer
  // final tx = await ethService.createTransaction(
  //   params: TransferParamsETH(
  //     to: '0x077B122c047a58174f1e8B011C8A6F768C0AC190',
  //     from: walletInfo.address,
  //     amount: BigRational.parseDecimal('0.001'),
  //     chainId: _chainId,
  //     supportsEIP1559: true, // true | false
  //     tokenDecimal: 6, // USDC
  //     tokenContractAddress: _usdcContractAddress,
  //     tokenWalletType: TokenWalletType.child,
  //     tokenName: 'USDC',
  //   ),
  //   masterKey: '',
  // );

  // ETH transfer
  final tx = await ethService.createTransaction(
    params: TransferParamsETH(
      to: '0x077B122c047a58174f1e8B011C8A6F768C0AC190',
      from: walletInfo.address,
      amount: BigRational.parseDecimal('0.001'),
      chainId: _chainId,
      supportsEIP1559: true,
      // true | false
      tokenDecimal: 18,
      // ETH
      tokenWalletType: TokenWalletType.master,
      tokenName: 'ETH',
      // message: 'hi',
    ),
    masterKey: '',
  );
  logger.logInfoMessage('arbExample', 'TX: $tx');
  final sentTx = await _rpc.request(
    EthereumRequestSendRawTransaction(transaction: tx),
  );
  logger.logInfoMessage('arbExample', 'SENT: $sentTx');
}
