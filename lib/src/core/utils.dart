import 'dart:convert';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip.dart' as bip;
import 'package:flutter/foundation.dart';
import 'package:on_chain/tron/src/keys/private_key.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:tron_energy_wallet_core/src/core/core.dart';

/// Check and prepare a message for sending via OP_RETURN on the BTC network
String? convertMessageForOpReturn(String? message, [TRLogger? logger]) {
  if (message == null || message.isEmpty) return null;

  // Encode the message into bytes (UTF-8)
  var messageBytes = utf8.encode(message);

  // Check length and trim if longer than 80 bytes
  if (messageBytes.length > 80) {
    messageBytes = messageBytes.sublist(0, 80);
    (logger ?? InAppLogger()).logInfoMessage(
      'convertMessageForOpReturn',
      'The message was truncated to 80 bytes',
    );
  }
  return utf8.decode(messageBytes, allowMalformed: true);
}

/// A service class that encapsulates the logic of generating private keys for
/// multiple blockchains from a single mnemonic seed phrase
class KeyGenerator {
  /// A service class that encapsulates the logic of generating private keys for
  /// multiple blockchains from a single mnemonic seed phrase
  KeyGenerator({required String mnemonic})
    : _mnemonic = bip.Mnemonic.fromString(mnemonic);

  final bip.Mnemonic _mnemonic;

  /// Derives and returns the private key for the TRON blockchain from the
  /// stored mnemonic.
  Future<TronPrivateKey> generateForTron() async {
    return compute<bip.Mnemonic, TronPrivateKey>(
      (m) {
        final seed = bip.Bip39SeedGenerator(m).generate();
        // Derive a TRON private key from the seed
        final bip44 = bip.Bip44.fromSeed(seed, bip.Bip44Coins.tron);
        // Derive a child key using the default path (first account)
        final childKey = bip44.deriveDefaultPath;
        return TronPrivateKey.fromBytes(childKey.privateKey.raw);
      },
      _mnemonic,
    );
  }

  /// Derives and returns the private key for the TON blockchain from the
  /// stored mnemonic.
  Future<TonPrivateKey> generateForTon() async {
    return compute<bip.Mnemonic, TonPrivateKey>(
      (m) {
        final seed = bip.TonSeedGenerator(m).generate();
        return TonPrivateKey.fromBytes(seed);
      },
      _mnemonic,
    );
  }

  /// Derives and returns the private key for the Bitcoin blockchain from
  /// the stored mnemonic.
  Future<ECPrivate> generateForBitcoin() async {
    return compute<bip.Mnemonic, ECPrivate>(
      (m) {
        final mnemonicGenerated = bip.Bip39SeedGenerator(m).generate();
        final bip32 = bip.Bip32Slip10Secp256k1.fromSeed(mnemonicGenerated);
        // BIP-86 m/86'/0'/0'/0/0 - for taproot
        // BIP-84 m/84'/0'/0'/0/0 - for SegWit
        // BIP-49 "m/49'/0'/0'/0/0" - for SegWit in compatibility mode with legacy wallets
        final bipBase = bip32.derivePath(BtcBipPath.bip86taproot.path);
        return ECPrivate.fromBytes(bipBase.privateKey.raw);
      },
      _mnemonic,
    );
  }
}
