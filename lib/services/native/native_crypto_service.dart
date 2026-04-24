import 'dart:convert';
import 'dart:typed_data';

// 1. Updated import to use the official sodium package
import 'package:sodium/sodium_sumo.dart';

import '../../core/utils/logger.dart';

class NativeEd25519KeyPair {
  final Uint8List publicKey;
  final Uint8List secretKey;

  const NativeEd25519KeyPair({
    required this.publicKey,
    required this.secretKey,
  });

  Map<String, String> toBase64Map() => {
        'publicKey': base64Encode(publicKey),
        'secretKey': base64Encode(secretKey),
      };
}

class NativeX25519KeyPair {
  final Uint8List publicKey;
  final Uint8List secretKey;

  const NativeX25519KeyPair({
    required this.publicKey,
    required this.secretKey,
  });

  Map<String, String> toBase64Map() => {
        'publicKey': base64Encode(publicKey),
        'secretKey': base64Encode(secretKey),
      };
}

/// Wraps libsodium (via [sodium]) to provide authenticated encryption.
///
/// Uses **XChaCha20-Poly1305-IETF** — the recommended AEAD construction in
/// libsodium. It is hardware-accelerated on modern CPUs and provides 192-bit
/// nonces (no collision risk even with random nonces).
///
/// Always call [init] before any other method (called from [CryptoService]).
class NativeCryptoService {
  NativeCryptoService._();
  static final instance = NativeCryptoService._();

  late final SodiumSumo _sodium;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    // 2. Initialization remains identical
    _sodium = await SodiumSumoInit.init(); 
    _ready = true;
    Log.i('[NativeCrypto] libsodium initialised — '
        'XChaCha20-Poly1305-IETF AEAD ready');
  }

  // ── XChaCha20-Poly1305-IETF AEAD ─────────────────────────────────────────

  /// Generates a random 256-bit symmetric key.
  Uint8List generateKey() =>
      _sodium.crypto.aeadXChaCha20Poly1305IETF.keygen().extractBytes();

  /// Generates a random 192-bit nonce (24 bytes for XChaCha20).
  Uint8List generateNonce() => _sodium.randombytes
      .buf(_sodium.crypto.aeadXChaCha20Poly1305IETF.nonceBytes);

  /// Encrypts [plaintext] with [key] and [nonce].
  /// Returns the ciphertext with the 16-byte Poly1305 auth tag appended.
  Uint8List encrypt({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List nonce,
    Uint8List? additionalData,
  }) {
    return _sodium.crypto.aeadXChaCha20Poly1305IETF.encrypt(
      message: plaintext,
      nonce: nonce,
      key: SecureKey.fromList(_sodium, key),
      additionalData: additionalData,
    );
  }

  /// Decrypts [ciphertext] (with appended Poly1305 tag).
  /// Throws [SodiumException] if authentication fails.
  Uint8List decrypt({
    required Uint8List ciphertext,
    required Uint8List key,
    required Uint8List nonce,
    Uint8List? additionalData,
  }) {
    return _sodium.crypto.aeadXChaCha20Poly1305IETF.decrypt(
      cipherText: ciphertext,
      nonce: nonce,
      key: SecureKey.fromList(_sodium, key),
      additionalData: additionalData,
    );
  }

  // ── Ed25519 Key Generation ────────────────────────────────────────────────

  /// Generates an Ed25519 identity keypair.
  /// Returns {'publicKey': base64, 'secretKey': base64}.
  Map<String, String> generateEd25519KeyPair() {
    return generateEd25519KeyPairRaw().toBase64Map();
  }

  /// Generates an Ed25519 identity keypair as raw bytes.
  NativeEd25519KeyPair generateEd25519KeyPairRaw() {
    final kp = _sodium.crypto.sign.keyPair();
    return NativeEd25519KeyPair(
      publicKey: kp.publicKey,
      secretKey: kp.secretKey.extractBytes(),
    );
  }

  // ── X25519 Key Exchange ───────────────────────────────────────────────────

  /// Generates an X25519 keypair for ECDH session key derivation.
  Map<String, String> generateX25519KeyPair() {
    return generateX25519KeyPairRaw().toBase64Map();
  }

  /// Generates an X25519 keypair for ECDH session key derivation as raw bytes.
  NativeX25519KeyPair generateX25519KeyPairRaw() {
    final kp = _sodium.crypto.box.keyPair();
    return NativeX25519KeyPair(
      publicKey: kp.publicKey,
      secretKey: kp.secretKey.extractBytes(),
    );
  }

  /// Derives a 256-bit shared session key from our X25519 secret key and
  /// the remote's X25519 public key via Curve25519 scalar multiplication.
  Uint8List deriveSharedKey({
    required Uint8List localSecretKey,
    required Uint8List remotePublicKey,
  }) {
    return _sodium.crypto.scalarmult(
      n: SecureKey.fromList(_sodium, localSecretKey),
      p: remotePublicKey,
    ).extractBytes();
  }

  SodiumSumo get sodium => _sodium;
}