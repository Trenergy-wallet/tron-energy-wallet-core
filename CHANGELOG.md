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
