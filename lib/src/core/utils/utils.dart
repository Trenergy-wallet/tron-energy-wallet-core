// For future purposes
// ignore_for_file: unused_field

import 'dart:isolate';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip.dart' as bip;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:on_chain/tron/src/keys/private_key.dart';
import 'package:ton_dart/ton_dart.dart';

/// A service class that encapsulates the logic of generating private keys for
/// multiple blockchains from a single mnemonic seed phrase
class KeyGenerator {
  /// A service class that encapsulates the logic of generating private keys for
  /// multiple blockchains from a single mnemonic seed phrase
  KeyGenerator({required String mnemonic})
    : mnemonic = bip.Mnemonic.fromString(mnemonic);

  /// Mnemonic
  @protected
  final bip.Mnemonic mnemonic;

  /// Derives and returns the private key for the TRON blockchain from the
  /// stored mnemonic.
  Future<TronPrivateKey> generateForTron() async {
    return Isolate.run(() {
      final seed = bip.Bip39SeedGenerator(mnemonic).generate();
      // Derive a TRON private key from the seed
      final bip44 = bip.Bip44.fromSeed(seed, bip.Bip44Coins.tron);
      // Derive a child key using the default path (first account)
      final childKey = bip44.deriveDefaultPath;
      return TronPrivateKey.fromBytes(childKey.privateKey.raw);
    });
  }

  /// Derives and returns the private key for the TON blockchain from the
  /// stored mnemonic.
  Future<TonPrivateKey> generateForTon() async {
    return Isolate.run(() {
      final seed = bip.TonSeedGenerator(mnemonic).generate();
      return TonPrivateKey.fromBytes(seed);
    });
  }

  /// Derives and returns the private key for the Bitcoin blockchain from
  /// the stored mnemonic.
  Future<ECPrivate> generateForBitcoin() async {
    return Isolate.run(() {
      final mnemonicGenerated = bip.Bip39SeedGenerator(mnemonic).generate();
      final bip32 = bip.Bip32Slip10Secp256k1.fromSeed(mnemonicGenerated);
      // BIP-86 m/86'/0'/0'/0/0 - for taproot
      // BIP-84 m/84'/0'/0'/0/0 - for SegWit
      // BIP-49 "m/49'/0'/0'/0/0" - for SegWit in compatibility mode with legacy wallets
      final bipBase = bip32.derivePath(_BtcBipPath.bip86taproot.path);
      return ECPrivate.fromBytes(bipBase.privateKey.raw);
    });
  }
}

/// bip32.derivePath params
enum _BtcBipPath {
  /// For SegWit in compatibility mode with legacy wallets
  bip49segwit("m/49'/0'/0'/0/0"),

  /// SegWit
  bip84segwit("m/84'/0'/0'/0/0"),

  /// Taproot
  bip86taproot("m/86'/0'/0'/0/0");

  const _BtcBipPath(this.path);

  /// Key derivation path
  final String path;
}
