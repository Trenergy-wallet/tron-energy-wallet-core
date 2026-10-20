import 'dart:typed_data';

/// Device key for DPoP proofs
///
/// The implementation owns the private key and signs with it. The core does
/// not know where the key lives: the app keeps it in the Secure Enclave /
/// Android Keystore.
abstract interface class DpopSigner {
  /// Public key: uncompressed P-256 point, 0x04 ‖ X ‖ Y (65 bytes)
  Future<Uint8List> publicKey();

  /// ECDSA P-256 over SHA-256([data]) as raw r ‖ s, 32 bytes each (64 bytes)
  ///
  /// Not DER: JWS (RFC 7518 §3.4) requires the raw form
  Future<Uint8List> sign(Uint8List data);
}
