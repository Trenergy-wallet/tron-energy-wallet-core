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
