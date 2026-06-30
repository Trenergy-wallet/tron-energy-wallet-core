/// Parameters of a transaction requested by a dapp over WalletConnect
/// (`eth_sendTransaction` / `eth_signTransaction`).
///
/// Unlike `TransferParamsETH` this is a raw, low-level description of an
/// arbitrary EVM transaction: it carries opaque [data] (calldata) and an
/// explicit [to] without any assumption about coin vs ERC-20 transfer, so it
/// can represent any contract interaction the dapp asks for.
///
/// Hex fields coming from the JSON-RPC payload (`0x...`) must be decoded into
/// these typed values by the caller; the core treats the values as-is.
///
/// Fields left `null` are resolved by the service against the node when the
/// transaction is built (see `createDappTransaction`):
/// - [nonce] — fetched via the current transaction count;
/// - [gasLimit] — estimated (with a safety buffer);
/// - fee fields — fetched from the node (with a safety buffer).
///
/// Values explicitly provided by the dapp are respected verbatim — no buffer
/// is applied to them.
class DappTransactionParamsETH {
  /// Parameters of a dapp transaction.
  const DappTransactionParamsETH({
    required this.from,
    required this.to,
    required this.chainId,
    required this.supportsEIP1559,
    this.value,
    this.data,
    this.nonce,
    this.gasLimit,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
  });

  /// Sender address; must match the wallet that signs the transaction.
  final String from;

  /// Recipient address (contract or EOA).
  final String to;

  /// Amount of native coin to send, in wei. `null` is treated as `0`.
  final BigInt? value;

  /// Raw calldata. `null` is treated as empty.
  final List<int>? data;

  /// Transaction nonce. `null` => fetched from the node.
  final int? nonce;

  /// Gas limit. `null` => estimated with a safety buffer.
  final BigInt? gasLimit;

  /// Legacy gas price, in wei. `null` (for a legacy tx) => fetched.
  final BigInt? gasPrice;

  /// EIP-1559 max fee per gas, in wei. `null` (for an EIP-1559 tx) => fetched.
  final BigInt? maxFeePerGas;

  /// EIP-1559 max priority fee per gas, in wei. `null` => fetched.
  final BigInt? maxPriorityFeePerGas;

  /// Target chain id.
  final int chainId;

  /// Whether the target chain supports EIP-1559 (type-2) transactions.
  final bool supportsEIP1559;
}
