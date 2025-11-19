import 'package:on_chain/solidity/contract/fragments.dart';

/// Ethereum abi fragment for the transfer operation
final AbiFunctionFragment ethTransferAbiFragment = AbiFunctionFragment.fromJson(
  const {
    'inputs': [
      {'internalType': 'address', 'name': 'to', 'type': 'address'},
      {'internalType': 'uint256', 'name': 'value', 'type': 'uint256'},
    ],
    'name': 'transfer',
    'stateMutability': 'nonpayable',
    'type': 'function',
  },
);

/// Ethereum abi fragment for the ERC20 token balance
final AbiFunctionFragment erc20BalanceAbiFragment =
    AbiFunctionFragment.fromJson(const {
      'inputs': [
        {'internalType': 'address', 'name': 'account', 'type': 'address'},
      ],
      'name': 'balanceOf',
      'outputs': [
        {'internalType': 'uint256', 'name': '', 'type': 'uint256'},
      ],
      'stateMutability': 'view',
      'type': 'function',
    });
