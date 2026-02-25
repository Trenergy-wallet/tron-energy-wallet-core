import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain/ethereum/src/rpc/methds/send_raw_transaction.dart';
import 'package:on_chain/ethereum/src/rpc/provider/provider.dart';
import 'package:tr_logger/tr_logger.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

final _rpc = EthereumProvider(
  EthereumHTTPProvider(
    'https://rpc.ankr.com/eth_sepolia/',
    'your-api-token',
  ),
);

// ETH Sepolia
const _chainIdTestNet = 11155111;
// ETH decimal: 18
// USDC decimal: 6
// USDC contractAddress:
const _usdcContractAddress = '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238';

Future<void> main() async {
  const name = 'ETHExample';
  final logger = InAppLogger()..usePrint = true;
  final service = TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.ethereum,
    rpc: _rpc,
    logger: logger,
    getSigningKey: (_) async => 'your-mnemonic',
  );

  final walletInfo = await service.initializeWalletAndGetInfo(
    masterKey: '',
  );

  logger.logInfoMessage('ethExample', 'Main address: ${walletInfo.address}');

  // final feeEstimate = await service.tryEstimateFee(
  //   params: TransferParamsETH(
  //     to: '0x4204711Fa7FE0a884Ea057987D4E2AC1753181c0',
  //     from: walletInfo.address,
  //     amount: BigRational.parseDecimal('0.001'),
  //     chainId: _chainIdTestNet,
  //     supportsEIP1559: true, // true | false
  //     tokenDecimal: 18,
  //     tokenWalletType: TokenWalletType.master,
  //   ),
  //   // message: 'hi',
  // );
  // logger.logInfoMessage(name, 'Est fee: $feeEstimate');

  // USDC Transfer
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

  logger.logInfoMessage('ethExample', 'TX: $tx');
  final sentTx = await _rpc.request(
    EthereumRequestSendRawTransaction(transaction: tx),
  );
  logger.logInfoMessage('ethExample', 'SENT: $sentTx');
}
