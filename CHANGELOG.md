## 3.1.0

### Dependencies

- `blockchain_utils` `^6.0.0` -> `^7.1.0`. This forces the whole mrtnetwork stack to move in
  lockstep: `on_chain` `^8.1.0`, `bitcoin_base` `^7.3.0`, `ton_dart` `^2.3.0`. Intermediate
  combinations do not resolve
- `on_chain` switched from the git ref back to the published `^8.1.0` — the memo and
  `toEstimate` fixes we were carrying are released now
- `tr_ton_wallet_service` `v1.1.0` -> `v1.2.0`

### Added

- `AppBlockchain.isEvm` — marks EVM-compatible networks
- `TronHTTPProvider` now serves GET requests as well: `on_chain` 8.1.0 introduced GET endpoints
  for Tron, and the provider used to POST unconditionally

### Breaking changes

- HTTP providers moved to the new `blockchain_utils` service contract: they are now mixed in
  (`with EthereumServiceProvider` and so on) instead of implemented, `doRequest` lost its type
  parameter, `toUri`/`body()` became `encodeUrl`/`encodeBody`, and `toResponse` takes a named
  `statusCode`. Custom provider implementations have to be updated the same way
- The request timeout field is now called `requestTimeout` everywhere:
  `EthereumHTTPProvider.defaultTimeOut`, `SolanaHTTPProvider.defaultRequestTimeout` and
  `TronHTTPProvider.defaultRequestTimeout` are gone
- `TransactionsServiceEthereumImpl.supportedBlockchains` removed — use `AppBlockchain.isEvm`
- **TON testnet wallet addresses have changed.** `ton_dart` 2.3.0 split the old `TonChainId`
  into `TonWorkChain` and `TonChainId`; up to 2.2.0 `TonChainId.testnet` implied workchain `-1`,
  so testnet wallets were derived in the masterchain. They are now derived in the basechain on
  both networks. Mainnet addresses are unchanged. Stored testnet addresses have to be
  invalidated, and stale records cleaned on the backend
- **Bitcoin RBF transactions serialize differently, so their txids change.** `bitcoin_base` 7.2.0
  replaced the RBF nSequence `0x00000001` with the canonical `0xFFFFFFFD` and applies it to every
  input instead of the first one only. The previous value also imposed an unintended BIP68
  relative timelock of one block, which would have rejected any spend of an unconfirmed UTXO
- Address strings reaching the TON service are now validated strictly (`TonAddressParser`):
  a raw address with a wrong-length account hash used to be accepted since `blockchain_utils`
  7.1.0 and failed only after signing and broadcasting
- Anyone constructing `TonProvider` directly now passes the api type as a second positional
  argument: `TonProvider(service, service.api)`

## 3.0.0

### Added

- Gasfree transfers for EVM networks: `TransactionsServiceEthereumGasFreeImpl` (EIP-7702 +
  ERC-20 paymaster). Gas is paid in the token being sent, the sender needs no native coin.
  The service produces a ready `eth_sendUserOperation` JSON-RPC body for the backend to relay
- `TransferParamsGasFreeETH` and `GasfreeEstimate` — transfer params and a cacheable result of
  a precise operation estimation (a single paid provider round covers both the displayed fee
  and the final UserOperation)
- `LoggingHttpClient` — an http client wrapper that logs RPC requests and responses

### Breaking changes

- `FeeType.gasFree` added — exhaustive switches over `FeeType` have to be updated
- `Fees.feeForType` throws `ArgumentError` for `FeeType.gasFree`: the selector serves Bitcoin
  fees only, where gasfree is never applicable
- `TransactionsServiceEthereumImpl` and its subclasses (`TransactionsServiceBaseImpl`,
  `TransactionsServiceOptimismImpl`) throw on `FeeType.gasFree`, use
  `TransactionsServiceEthereumGasFreeImpl` instead
- The `logger` parameter of the transactions services no longer falls back to `InAppLogger`:
  when it is omitted, logging (including the RPC one) is disabled
- The dead `forceUpdateNonce` parameter has been removed

### Dependencies

- `permissionless` added

## 2.2.1

* EVM fixes

## 2.2.0

* Dependencies updated

## 2.1.1

* Default request timeout updated

## 2.1.0

### Added

- SOLANA network support

## 2.0.0

### Breaking changes

- Major refactoring and cleanup of the repository interfaces. The `createTransaction` method now
  accepts a `TransferParams` object instead of individual parameters
- Added corresponding `TransferParams` classes for all supported blockchains

## 1.7.0

### Added

- Base network support

## 1.6.2

- added fee buffer for EVM legacy transactions

## 1.6.1

- Arbitrum slug fix

## 1.6.0

### Added

- Optimism network support

## 1.5.0

### Added

- Polygon network support

## 1.4.0

### Added

- Arbitrum network support

### Breaking changes

- Removed `postTransaction` from `TransactionsService`
- Renamed public methods in `TransactionsService` to better reflect their contracts
- Removed `LocalRepository` dependency from `TransactionsService` constructor  
  New required parameters:
    - `getSigningKey`
    - `getAuthToken`

## 1.3.0

* [BREAKING] Amount is BigRational

## 1.2.1

* Dependency update

## 1.2.0

* NEW blockchain: BNB Smart Chain (BSC)

## 1.1.0

* NEW blockchain: Ethereum

## 1.0.7

* Btc dust calculations

## 1.0.5

* Https dependency migration

## 1.0.4

* Added Memo for TRON
* New fields in AppAsset: hold, availableBalance
* Example updated

## 1.0.2

* tr_ton_wallet_service and tr_logger dependencies updated

## 1.0.1

* Updated dependencies

## 1.0.0

* Initial Open Source release.
