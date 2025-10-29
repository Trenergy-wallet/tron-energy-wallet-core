/// Ethereum abi fragment for the transfer operation
const Map<String, Object> ethTransferAbiFragment = {
  'inputs': [
    {'internalType': 'address', 'name': 'to', 'type': 'address'},
    {'internalType': 'uint256', 'name': 'value', 'type': 'uint256'},
  ],
  'name': 'transfer',
  'stateMutability': 'nonpayable',
  'type': 'function',
};
