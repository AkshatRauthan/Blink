import 'dart:convert';
import 'dart:typed_data';

import '../../core/errors/blink_exception.dart';
import '../../core/utils/logger.dart';
import '../native/native_crypto_service.dart';

/// Manages the device's long-lived Ed25519 identity keypair.
///
/// The keypair is generated once on first launch and persisted in
/// platform secure storage (Keystore on Android, Secret Service on Linux,
/// DPAPI on Windows).
///
/// The public key is shared during QR handshakes. The secret key never leaves
/// the device.
class KeyStoreService {
  KeyStoreService._();
  static final instance = KeyStoreService._();

  Map<String, String>? _cachedKeyPair;

  /// Generates and persists a keypair if one doesn't already exist.
  Future<void> ensureIdentityKey() async {
    try {
      await NativeCryptoService.instance.init();
      if (_cachedKeyPair != null) return;
      // TODO: Check secure storage for existing keypair
      // If not found, generate and store a new one
      _cachedKeyPair = NativeCryptoService.instance.generateEd25519KeyPair();
      // TODO: Persist to flutter_secure_storage
      Log.i(
        'Identity keypair ready',
        source: LogSource.security,
        component: 'KeyStoreService',
      );
    } catch (e) {
      throw KeyStoreException('Failed to initialise identity key', cause: e);
    }
  }

  /// Returns the base64-encoded Ed25519 public key for this device.
  String get publicKeyBase64 {
    if (_cachedKeyPair == null) {
      throw const KeyStoreException('Identity key not yet initialised');
    }
    return _cachedKeyPair!['publicKey']!;
  }

  /// Returns the raw 32-byte public key.
  Uint8List get publicKeyBytes => base64Decode(publicKeyBase64);

  /// Generates a fresh ephemeral X25519 keypair for session key derivation.
  ///
  /// This keypair is not persisted and should be treated as short-lived.
  Map<String, String> generateEphemeralX25519KeyPair() {
    return NativeCryptoService.instance.generateX25519KeyPair();
  }
}
