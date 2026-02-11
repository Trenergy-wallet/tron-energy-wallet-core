import 'package:on_chain/solidity/contract/fragments.dart';

/// ABI fragment for getL1Fee(bytes calldata _data) on GasPriceOracle
/// (Optimism)
final AbiFunctionFragment optimismL1FeeAbiFragment =
    AbiFunctionFragment.fromJson(
      const {
        'inputs': [
          {'internalType': 'bytes', 'name': '_data', 'type': 'bytes'},
        ],
        'name': 'getL1Fee',
        'outputs': [
          {'internalType': 'uint256', 'name': '', 'type': 'uint256'},
        ],
        'stateMutability': 'view',
        'type': 'function',
      },
    );
