import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain/ethereum/src/models/block_tag.dart';
import 'package:on_chain/ethereum/src/rpc/core/core.dart';
import 'package:on_chain/ethereum/src/rpc/core/methods.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/abi/abi.dart';

/// Eth rpc request to get the balance of the token
class RPCERC20TokenBalance extends EthereumRequest<BigInt, String> {
  /// Eth rpc request to get the balance of the token
  RPCERC20TokenBalance(this.contractAddress, this.accountAddress)
    : super(blockNumber: BlockTagOrNumber.latest);

  @override
  String get method => EthereumMethods.call.value;

  /// Token contract address
  final String contractAddress;

  /// Wallet address
  final SolidityAddress accountAddress;

  @override
  BigInt onResonse(String result) {
    return EthereumRequest.onBigintResponse(result);
  }

  @override
  List<dynamic> toJson() {
    return [
      {
        'to': contractAddress,
        'data': BytesUtils.toHexString(
          erc20BalanceAbiFragment.encode([accountAddress]),
          prefix: '0x',
        ),
      },
      blockNumber,
    ];
  }
}
