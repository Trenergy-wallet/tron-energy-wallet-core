import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain/ethereum/src/models/block_tag.dart';
import 'package:on_chain/ethereum/src/rpc/core/core.dart';
import 'package:on_chain/ethereum/src/rpc/core/methods.dart';
import 'package:tron_energy_wallet_core/src/features/networks/ethereum/abi/abi_optimism.dart';

/// Eth rpc request to get the balance of the token
class RPCOpGetL1Fee extends EthereumRequest<BigInt, String> {
  /// Eth rpc request to get the balance of the token
  RPCOpGetL1Fee(this.rawTxBytes) : super(blockNumber: BlockTagOrNumber.latest);

  @override
  String get method => EthereumMethods.call.value;

  /// Token contract address
  final List<int> rawTxBytes;

  @override
  BigInt onResonse(String result) {
    return EthereumRequest.onBigintResponse(result);
  }

  @override
  List<dynamic> toJson() {
    return [
      {
        // Optimism system contract address for GasPriceOracle
        'to': '0x420000000000000000000000000000000000000F',
        'data': BytesUtils.toHexString(
          optimismL1FeeAbiFragment.encode([rawTxBytes]),
          prefix: '0x',
        ),
      },
      blockNumber,
    ];
  }
}
