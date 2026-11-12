import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart'
    hide Either, Left, Right;
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Public BIP-39 test vector, not a real wallet
const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

/// m/84'/2'/0'/0/0 of [_mnemonic]: matches the blockchain_utils BIP-84
/// Litecoin encoder and the default P2WPKH path of the reference wallet
const _ltcMainnetAddress = 'ltc1qjmxnz78nmc8nq77wuxh25n2es7rzm5c2rkk4wh';
const _ltcTestnetAddress = 'tltc1qjmxnz78nmc8nq77wuxh25n2es7rzm5c25y4uaa';

/// m/86'/0'/0'/0/0 of [_mnemonic] (BIP-86 test vector)
const _btcTaprootAddress =
    'bc1p5cyxnuxmeuwuvkwfem96lqzszd02n6xdcjrs20cac6yqjjwudpxqkedrcr';

/// m/84'/0'/0'/0/0 of [_mnemonic] (BIP-84 test vector)
const _btcSegwitAddress = 'bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu';

final String _utxoTxId = 'aa' * 32;

/// Node with a single confirmed UTXO and no pending transactions
final class _FakeNodeRepo implements BTCNodeRepo {
  _FakeNodeRepo({this.utxos = const [], this.error});

  final List<AppUtxo> utxos;

  final AppExceptionWithCode? error;

  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV2({
    required String address,
    bool? confirmed,
  }) async => error != null ? Left(error!) : Right(utxos);

  @override
  Future<Either<AppExceptionWithCode, List<AppUtxo>>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  }) async => const Right(<AppUtxo>[]);

  @override
  Future<Either<AppExceptionWithCode, TransactionBtcNode>> fetchTransaction({
    required String txId,
  }) => throw UnimplementedError();
}

const _fees = Fees(fastestFee: 20, halfHourFee: 10, economyFee: 5);

EstimateFeeModel _estimate([Fees fees = _fees]) => EstimateFeeModel(
  fee: BigRational.zero,
  energy: 0,
  fees: fees,
  txDustThreshold: BigInt.from(546),
);

TransactionsServiceBTCImpl _service({
  AppBlockchain appBlockchain = AppBlockchain.litecoin,
  BasedUtxoNetwork network = LitecoinNetwork.mainnet,
  String mnemonic = _mnemonic,
  BTCNodeRepo? nodeRepo,
  Fees fees = _fees,
}) => TransactionsServiceBTCImpl(
  appBlockchain: appBlockchain,
  network: network,
  btcNodeRepo:
      nodeRepo ??
      _FakeNodeRepo(
        utxos: [
          AppUtxo(
            txid: _utxoTxId,
            vout: 0,
            value: BigInt.from(1000000),
            height: 1,
            confirmations: 10,
          ),
        ],
      ),
  getSigningKey: (_) async => mnemonic,
  estimateFee:
      ({
        required amount,
        required appBlockchain,
        required tokenWalletType,
        recipientAddress,
        tokenContractAddress,
      }) async => Right(_estimate(fees)),
);

/// Native SegWit address of another key
String _recipient([BasedUtxoNetwork network = LitecoinNetwork.mainnet]) =>
    ECPrivate.fromBytes(
      List.filled(32, 1),
    ).getPublic().toSegwitAddress().toAddress(network);

TransferParamsBTC _params({
  String? to,
  String from = _ltcMainnetAddress,
  String amount = '0.001',
  AppBlockchain appBlockchain = AppBlockchain.litecoin,
  TokenWalletType tokenWalletType = TokenWalletType.master,
  String? message,
  EstimateFeeModel? userApprovedFee,
  String? txIdToPumpFeeBTC,
}) => TransferParamsBTC(
  to: to ?? _recipient(),
  from: from,
  amount: BigRational.parseDecimal(amount),
  tokenWalletType: tokenWalletType,
  feeType: FeeType.optimal,
  message: message,
  userApprovedFee: userApprovedFee,
  txIdToPumpFeeBTC: txIdToPumpFeeBTC,
  appBlockchain: appBlockchain,
);

Matcher _throwsCode(ExceptionCode code) => throwsA(
  isA<AppExceptionWithCode>().having((e) => e.code, 'code', code),
);

void main() {
  group('TransactionsServiceBTCImpl.initializeWalletAndGetInfo', () {
    test('litecoin mainnet: native SegWit address', () async {
      final info = await _service().initializeWalletAndGetInfo(masterKey: '');
      expect(info.address, _ltcMainnetAddress);
    });

    test('litecoin testnet: native SegWit address', () async {
      final info = await _service(
        network: LitecoinNetwork.testnet,
      ).initializeWalletAndGetInfo(masterKey: '');
      expect(info.address, _ltcTestnetAddress);
    });

    test('bitcoin by default: Taproot address', () async {
      final service = TransactionsServiceBTCImpl(
        network: BitcoinNetwork.mainnet,
        btcNodeRepo: _FakeNodeRepo(),
        getSigningKey: (_) async => _mnemonic,
        estimateFee:
            ({
              required amount,
              required appBlockchain,
              required tokenWalletType,
              recipientAddress,
              tokenContractAddress,
            }) async => Right(_estimate()),
      );
      expect(service.appBlockchain, AppBlockchain.bitcoin);
      final info = await service.initializeWalletAndGetInfo(masterKey: '');
      expect(info.address, _btcTaprootAddress);
    });

    test('THROWS unableToDecodeWallet when master key is null', () {
      expect(
        _service().initializeWalletAndGetInfo(),
        _throwsCode(ExceptionCode.unableToDecodeWallet),
      );
    });

    test('THROWS unableToRetrieveMnemonic when mnemonic is empty', () {
      expect(
        _service(mnemonic: '').initializeWalletAndGetInfo(masterKey: ''),
        _throwsCode(ExceptionCode.unableToRetrieveMnemonic),
      );
    });

    test('THROWS AppIncorrectBlockchainException on network mismatch', () {
      expect(
        _service(
          network: BitcoinNetwork.mainnet,
        ).initializeWalletAndGetInfo(masterKey: ''),
        throwsA(isA<AppIncorrectBlockchainException>()),
      );
      expect(
        _service(
          appBlockchain: AppBlockchain.bitcoin,
        ).initializeWalletAndGetInfo(masterKey: ''),
        throwsA(isA<AppIncorrectBlockchainException>()),
      );
    });

    test('THROWS AppBlockchainIsNotSupportedException for non UTXO', () {
      expect(
        _service(
          appBlockchain: AppBlockchain.ton,
        ).initializeWalletAndGetInfo(masterKey: ''),
        throwsA(isA<AppBlockchainIsNotSupportedException>()),
      );
    });
  });

  group('TransactionsServiceBTCImpl.spenderAddress', () {
    final publicKey = ECPrivate.fromBytes(List.filled(32, 1)).getPublic();

    test('bitcoin: Taproot, litecoin: native SegWit', () {
      expect(
        _service(appBlockchain: AppBlockchain.bitcoin).spenderAddress(
          publicKey,
        ),
        isA<P2trAddress>(),
      );
      expect(_service().spenderAddress(publicKey), isA<P2wpkhAddress>());
    });

    test('THROWS AppBlockchainIsNotSupportedException for non UTXO', () {
      expect(
        () => _service(appBlockchain: AppBlockchain.ton).spenderAddress(
          publicKey,
        ),
        throwsA(isA<AppBlockchainIsNotSupportedException>()),
      );
    });
  });

  group('TransactionsServiceBTCImpl.createTransaction bitcoin', () {
    test('still builds Taproot transaction', () async {
      final service = _service(
        appBlockchain: AppBlockchain.bitcoin,
        network: BitcoinNetwork.mainnet,
      );
      final raw = await service.createTransaction(
        params: _params(
          appBlockchain: AppBlockchain.bitcoin,
          from: _btcTaprootAddress,
          to: _btcSegwitAddress,
        ),
        masterKey: '',
      );
      final tx = BtcTransaction.deserialize(BytesUtils.fromHexString(raw));
      // Taproot key path witness: a single Schnorr signature
      expect(tx.witnesses.single.stack, hasLength(1));
      expect(tx.outputs, hasLength(2));
    });
  });

  group('TransactionsServiceBTCImpl.createTransaction litecoin', () {
    test('builds and signs P2WPKH transaction with change', () async {
      final service = _service();
      final params = _params();
      final prepared = await service.prepareTransactionAndCalculateSize(
        params: params,
        masterKey: '',
      );
      final raw = await service.createTransaction(
        params: params,
        masterKey: '',
      );
      final tx = BtcTransaction.deserialize(BytesUtils.fromHexString(raw));

      expect(tx.inputs.single.txId, _utxoTxId);
      // P2WPKH witness: signature + public key (Taproot would have one item)
      final witness = tx.witnesses.single.stack;
      expect(witness, hasLength(2));
      final publicKey = ECPublic.fromHex(witness[1]);
      expect(
        publicKey.toSegwitAddress().toAddress(LitecoinNetwork.mainnet),
        _ltcMainnetAddress,
      );
      // BIP-143 digest of the input: signature must be valid, not just present
      final digest = tx.getTransactionSegwitDigit(
        txInIndex: 0,
        script: publicKey.toAddress().toScriptPubKey(),
        amount: BigInt.from(1000000),
      );
      final signature = BytesUtils.fromHexString(witness[0]);
      expect(
        publicKey.verifyDerSignature(
          digest: digest,
          // Last byte is the sighash type
          signature: signature.sublist(0, signature.length - 1),
        ),
        isTrue,
      );

      final recipient = BitcoinNetworkAddress.parse(
        address: _recipient(),
        network: LitecoinNetwork.mainnet,
      ).baseAddress;
      final sent = tx.outputs.firstWhere(
        (o) => o.scriptPubKey == recipient.toScriptPubKey(),
      );
      expect(sent.amount, BigInt.from(100000));
      final change = tx.outputs.firstWhere(
        (o) => o.scriptPubKey == prepared.spender.toScriptPubKey(),
      );

      final fee = BigInt.from(1000000) - sent.amount - change.amount;
      // optimal = halfHourFee = 10 sat/vB
      expect(fee, BigInt.from(10 * prepared.transactionVSize));
    });

    test('adds OP_RETURN output for message', () async {
      final raw = await _service().createTransaction(
        params: _params(message: 'hello'),
        masterKey: '',
      );
      final tx = BtcTransaction.deserialize(BytesUtils.fromHexString(raw));
      expect(tx.outputs, hasLength(3));
      expect(tx.outputs.where((o) => o.amount == BigInt.zero), hasLength(1));
    });

    test('THROWS AppIncorrectBlockchainException for bitcoin params', () {
      expect(
        _service().createTransaction(
          params: _params(appBlockchain: AppBlockchain.bitcoin),
          masterKey: '',
        ),
        throwsA(isA<AppIncorrectBlockchainException>()),
      );
    });

    test('THROWS amountIsNotPositive for zero amount', () {
      expect(
        _service().createTransaction(
          params: _params(amount: '0'),
          masterKey: '',
        ),
        _throwsCode(ExceptionCode.amountIsNotPositive),
      );
    });

    test('THROWS unableToCreateTransaction for bitcoin recipient', () {
      expect(
        _service().createTransaction(
          params: _params(to: _btcSegwitAddress),
          masterKey: '',
        ),
        _throwsCode(ExceptionCode.unableToCreateTransaction),
      );
    });

    test('THROWS unableToCreateTransaction for Taproot recipient', () {
      // bitcoin_base does not support Taproot for Litecoin
      final ltcTaproot = SegwitBech32Encoder.encode(
        'ltc',
        1,
        List.filled(32, 1),
      );
      expect(
        _service().createTransaction(
          params: _params(to: ltcTaproot),
          masterKey: '',
        ),
        _throwsCode(ExceptionCode.unableToCreateTransaction),
      );
    });

    test('THROWS unableToCreateTransaction for empty txIdToPumpFee', () {
      expect(
        _service().createTransaction(
          params: _params(txIdToPumpFeeBTC: ''),
          masterKey: '',
        ),
        _throwsCode(ExceptionCode.unableToCreateTransaction),
      );
    });

    test('THROWS unableToDecodeWallet when from is not the wallet', () {
      expect(
        _service().createTransaction(
          params: _params(from: _recipient()),
          masterKey: '',
        ),
        _throwsCode(ExceptionCode.unableToDecodeWallet),
      );
    });

    test('THROWS tokenIsNotSupported for non master token', () {
      expect(
        _service().createTransaction(
          params: _params(tokenWalletType: TokenWalletType.child),
          masterKey: '',
        ),
        _throwsCode(ExceptionCode.tokenIsNotSupported),
      );
    });

    test('THROWS node error as is', () {
      final error = AppException(code: ExceptionCode.backendGeneralError);
      expect(
        _service(
          nodeRepo: _FakeNodeRepo(error: error),
        ).createTransaction(params: _params(), masterKey: ''),
        throwsA(same(error)),
      );
    });

    test('THROWS amountIsNotPositive without UTXO', () {
      expect(
        _service(
          nodeRepo: _FakeNodeRepo(),
        ).createTransaction(params: _params(), masterKey: ''),
        _throwsCode(ExceptionCode.amountIsNotPositive),
      );
    });

    test('THROWS amountIsNotPositive when balance does not cover fee', () {
      expect(
        _service().createTransaction(
          params: _params(amount: '0.01'),
          masterKey: '',
        ),
        _throwsCode(ExceptionCode.amountIsNotPositive),
      );
    });

    test('THROWS amountIsNotPositive for invalid fees', () {
      expect(
        _service(
          fees: Fees.invalid,
        ).createTransaction(params: _params(), masterKey: ''),
        _throwsCode(ExceptionCode.amountIsNotPositive),
      );
    });

    test('THROWS AppFeeChangedException when fee grew after approve', () {
      expect(
        _service().createTransaction(
          params: _params(
            userApprovedFee: _estimate(
              const Fees(fastestFee: 20, halfHourFee: 9, economyFee: 5),
            ),
          ),
          masterKey: '',
        ),
        throwsA(isA<AppFeeChangedException>()),
      );
    });
  });
}
