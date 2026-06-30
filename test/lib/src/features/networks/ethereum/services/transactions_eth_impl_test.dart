import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:test/test.dart';
import 'package:tron_energy_wallet_core/src/core/utils/utils.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Standard Hardhat test mnemonic — deterministic, well-known, safe to commit.
const _testMnemonic =
    'test test test test test test test test test test test junk';

/// Canonical EIP-712 example from the spec (Mail/Person), without a `version`
/// field — exactly how a dapp sends it over WalletConnect.
const _typedDataJson = '''
{
  "types": {
    "EIP712Domain": [
      {"name": "name", "type": "string"},
      {"name": "version", "type": "string"},
      {"name": "chainId", "type": "uint256"},
      {"name": "verifyingContract", "type": "address"}
    ],
    "Person": [
      {"name": "name", "type": "string"},
      {"name": "wallet", "type": "address"}
    ],
    "Mail": [
      {"name": "from", "type": "Person"},
      {"name": "to", "type": "Person"},
      {"name": "contents", "type": "string"}
    ]
  },
  "primaryType": "Mail",
  "domain": {
    "name": "Ether Mail",
    "version": "1",
    "chainId": 1,
    "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
  },
  "message": {
    "from": {"name": "Cow", "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"},
    "to": {"name": "Bob", "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"},
    "contents": "Hello, Bob!"
  }
}
''';

TransactionsServiceEthereumImpl _makeService({String mnemonic = _testMnemonic}) {
  return TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.ethereum,
    apiUri: 'https://rpc.invalid',
    getSigningKey: (_) async => mnemonic,
  );
}

/// Fake Ethereum JSON-RPC node: returns a canned `result` per method, and
/// throws on any method not in [results] (so tests can assert "no RPC call").
class _FakeEthService with EthereumServiceProvider {
  _FakeEthService(this.results, {this.onCall});

  /// method name -> JSON-RPC `result` value (e.g. a `0x...` quantity).
  final Map<String, Object?> results;
  final void Function(String method)? onCall;

  @override
  Future<EthereumServiceResponse<T>> doRequest<T>(
    EthereumRequestDetails params, {
    Duration? timeout,
  }) async {
    onCall?.call(params.method);
    if (!results.containsKey(params.method)) {
      throw StateError('unexpected RPC call: ${params.method}');
    }
    final envelope = {
      'id': params.requestID,
      'jsonrpc': '2.0',
      'result': results[params.method],
    };
    final bytes = StringUtils.encode(StringUtils.fromJson(envelope));
    return params.toResponse<T>(bytes, 200);
  }
}

TransactionsServiceEthereumImpl _makeServiceWithRpc(
  _FakeEthService svc, {
  String mnemonic = _testMnemonic,
}) {
  return TransactionsServiceEthereumImpl(
    appBlockchain: AppBlockchain.ethereum,
    rpc: EthereumProvider(svc),
    getSigningKey: (_) async => mnemonic,
  );
}

void main() {
  // Wallet derived from _testMnemonic via the same path the service uses.
  late final String walletAddress;
  late final List<int> pubKeyBytes;

  setUpAll(() async {
    final pk = await KeyGenerator(mnemonic: _testMnemonic).generateForEthereum();
    walletAddress = pk.publicKey().toAddress().address;
    pubKeyBytes = pk.publicKey().toBytes();
  });

  group('signPersonalMessageOrThrow', () {
    test('signs and the signature recovers to the wallet address', () async {
      final service = _makeService();
      final message = StringUtils.toBytes('Hello WalletConnect');

      final hex = await service.signPersonalMessageOrThrow(
        message: message,
        masterKey: 'master',
      );

      expect(hex, startsWith('0x'));
      final sigBytes = BytesUtils.fromHexString(hex);
      expect(sigBytes.length, 65);

      // The signature must be valid for our public key...
      final valid = ETHPublicKey.fromBytes(
        pubKeyBytes,
      ).verifyPersonalMessage(message, sigBytes);
      expect(valid, isTrue);

      // ...and recover to exactly our wallet address.
      final recovered = ETHPublicKey.getPublicKey(message, sigBytes);
      expect(recovered, isNotNull);
      expect(
        recovered!.toAddress().address.toLowerCase(),
        walletAddress.toLowerCase(),
      );
    });

    test('throws unableToRetrieveMnemonic when mnemonic is empty', () async {
      final service = _makeService(mnemonic: '');
      await expectLater(
        () => service.signPersonalMessageOrThrow(
          message: const [1, 2, 3],
          masterKey: 'master',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.unableToRetrieveMnemonic,
          ),
        ),
      );
    });
  });

  group('signTypedDataOrThrow', () {
    test('signs valid EIP-712 v4 typed data and verifies', () async {
      final service = _makeService();

      final hex = await service.signTypedDataOrThrow(
        typedDataJson: _typedDataJson,
        masterKey: 'master',
      );

      expect(hex, startsWith('0x'));
      final sigBytes = BytesUtils.fromHexString(hex);
      expect(sigBytes.length, 65);

      // Recompute the digest the same way the service does and verify the
      // signature over it (no EIP-191 prefix, digest already hashed).
      final decoded = StringUtils.toJson<Map<String, dynamic>>(_typedDataJson)
        ..['version'] = EIP712Version.v4.version;
      final digest = EIP712Base.fromJson(decoded).encode();

      final valid = ETHVerifier.fromKeyBytes(pubKeyBytes).verify(
        digest,
        sigBytes.sublist(0, 64),
        hashMessage: false,
      );
      expect(valid, isTrue);
    });

    test('throws invalidTypedData on malformed JSON', () async {
      final service = _makeService();
      await expectLater(
        () => service.signTypedDataOrThrow(
          typedDataJson: 'not a json at all',
          masterKey: 'master',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.invalidTypedData,
          ),
        ),
      );
    });

    test('throws invalidTypedData on structurally invalid typed data', () async {
      final service = _makeService();
      await expectLater(
        () => service.signTypedDataOrThrow(
          typedDataJson: '{"foo": "bar"}',
          masterKey: 'master',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.invalidTypedData,
          ),
        ),
      );
    });
  });

  group('signTransactionOrThrow', () {
    ETHTransaction legacyTx({required String from}) => ETHTransaction(
      type: ETHTransactionType.legacy,
      from: ETHAddress(from),
      to: ETHAddress(from),
      nonce: 0,
      gasLimit: BigInt.from(21000),
      gasPrice: BigInt.from(1000000000),
      value: BigInt.one,
      data: const [],
      chainId: BigInt.one,
    );

    test('signs a transaction whose from matches the wallet', () async {
      final service = _makeService();
      final signed = await service.signTransactionOrThrow(
        tx: legacyTx(from: walletAddress),
        masterKey: 'master',
      );
      expect(signed, startsWith('0x'));
      expect(signed.length, greaterThan(2));
    });

    test('throws dappFromAddressMismatch when from is foreign', () async {
      final service = _makeService();
      await expectLater(
        () => service.signTransactionOrThrow(
          tx: legacyTx(from: '0x000000000000000000000000000000000000dEaD'),
          masterKey: 'master',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.dappFromAddressMismatch,
          ),
        ),
      );
    });

    test('throws unableToRetrieveMnemonic when mnemonic is empty', () async {
      final service = _makeService(mnemonic: '');
      await expectLater(
        () => service.signTransactionOrThrow(
          tx: legacyTx(from: walletAddress),
          masterKey: 'master',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            ExceptionCode.unableToRetrieveMnemonic,
          ),
        ),
      );
    });
  });

  group('createDappTransaction', () {
    // 1 gwei and 21000, as `0x` quantities.
    const gasPriceHex = '0x3b9aca00'; // 1_000_000_000 wei
    const estimateGasHex = '0x5208'; // 21000
    final oneGwei = BigInt.from(1000000000);

    test('legacy: fills nonce / gasPrice / gasLimit from the node', () async {
      final svc = _FakeEthService({
        'eth_getTransactionCount': '0x5',
        'eth_gasPrice': gasPriceHex,
        'eth_estimateGas': estimateGasHex,
      });
      final service = _makeServiceWithRpc(svc);

      final tx = await service.createDappTransaction(
        params: DappTransactionParamsETH(
          from: walletAddress,
          to: walletAddress,
          chainId: 1,
          supportsEIP1559: false,
        ),
      );

      expect(tx.transactionType, ETHTransactionType.legacy);
      expect(tx.nonce, 5);
      // ethereum legacy buffer = *11/10
      expect(tx.gasPrice, oneGwei * BigInt.from(11) ~/ BigInt.from(10));
      // estimate buffer = *11/10
      expect(tx.gasLimit, BigInt.from(21000) * BigInt.from(11) ~/ BigInt.from(10));
      expect(tx.value, BigInt.zero);
      expect(tx.data, isEmpty);
    });

    test('respects dapp-provided fields without any RPC call', () async {
      var rpcCalled = false;
      final svc = _FakeEthService(const {}, onCall: (_) => rpcCalled = true);
      final service = _makeServiceWithRpc(svc);

      final tx = await service.createDappTransaction(
        params: DappTransactionParamsETH(
          from: walletAddress,
          to: walletAddress,
          chainId: 1,
          supportsEIP1559: true,
          nonce: 7,
          gasLimit: BigInt.from(50000),
          maxFeePerGas: BigInt.from(100),
          maxPriorityFeePerGas: BigInt.from(2),
          value: BigInt.from(123),
          data: const [1, 2, 3],
        ),
      );

      expect(rpcCalled, isFalse);
      expect(tx.transactionType, ETHTransactionType.eip1559);
      expect(tx.nonce, 7);
      expect(tx.gasLimit, BigInt.from(50000));
      expect(tx.maxFeePerGas, BigInt.from(100));
      expect(tx.maxPriorityFeePerGas, BigInt.from(2));
      expect(tx.value, BigInt.from(123));
      expect(tx.data, [1, 2, 3]);
    });

    test('estimateDappTransactionFee (legacy) = gasPrice * gasLimit', () async {
      final svc = _FakeEthService({
        'eth_getTransactionCount': '0x0',
        'eth_gasPrice': gasPriceHex,
        'eth_estimateGas': estimateGasHex,
      });
      final service = _makeServiceWithRpc(svc);

      final feeStr = await service.estimateDappTransactionFee(
        params: DappTransactionParamsETH(
          from: walletAddress,
          to: walletAddress,
          chainId: 1,
          supportsEIP1559: false,
        ),
      );

      final bufferedGasPrice = oneGwei * BigInt.from(11) ~/ BigInt.from(10);
      final bufferedGasLimit =
          BigInt.from(21000) * BigInt.from(11) ~/ BigInt.from(10);
      final expectedWei = bufferedGasPrice * bufferedGasLimit;
      expect(feeStr, ETHHelper.fromWei(expectedWei));
    });
  });
}
