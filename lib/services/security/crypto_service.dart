import 'dart:typed_data';

import '../../core/utils/logger.dart';
import '../native/native_crypto_service.dart';

/// High-level crypto API used by the transfer engine.
///
/// Delegates all cryptographic operations to [NativeCryptoService]
/// (libsodium via dart:ffi) for hardware-accelerated XChaCha20-Poly1305-IETF.
class CryptoService {
  CryptoService._();
  static final instance = CryptoService._();

  Future<void> init() async {
    await NativeCryptoService.instance.init();
    Log.i(
      'Initialised',
      source: LogSource.security,
      component: 'CryptoService',
    );
  }

  // ── Session Key ───────────────────────────────────────────────────────────

  /// Derives the 256-bit session key from our X25519 secret and
  /// the remote's X25519 public key (from the QR handshake).
  Uint8List deriveSessionKey({
    required Uint8List localX25519SecretKey,
    required Uint8List remoteX25519PublicKey,
  }) {
    return NativeCryptoService.instance.deriveSharedKey(
      localSecretKey: localX25519SecretKey,
      remotePublicKey: remoteX25519PublicKey,
    );
  }

  // ── Chunk Encryption ─────────────────────────────────────────────────────

  /// Encrypts a file chunk.
  /// Returns [nonce (24B) || ciphertext+tag].
  Uint8List encryptChunk(Uint8List plaintext, Uint8List sessionKey) {
    final nonce = NativeCryptoService.instance.generateNonce();
    final ciphertext = NativeCryptoService.instance.encrypt(
      plaintext: plaintext,
      key: sessionKey,
      nonce: nonce,
    );
    // Prepend 24-byte nonce so the receiver can decrypt without out-of-band exchange
    return Uint8List.fromList([...nonce, ...ciphertext]);
  }

  /// Decrypts a file chunk encrypted with [encryptChunk].
  /// XChaCha20-Poly1305-IETF uses 24-byte nonces.
  Uint8List decryptChunk(Uint8List encryptedChunk, Uint8List sessionKey) {
    const nonceLength = 24; // XChaCha20 nonce = 192 bits
    final nonce = encryptedChunk.sublist(0, nonceLength);
    final ciphertext = encryptedChunk.sublist(nonceLength);
    return NativeCryptoService.instance.decrypt(
      ciphertext: ciphertext,
      key: sessionKey,
      nonce: nonce,
    );
  }
}
