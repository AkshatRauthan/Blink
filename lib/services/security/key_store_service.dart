import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  static const _publicKeyKey = 'blink_ed25519_public';
  static const _secretKeyKey = 'blink_ed25519_secret';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
  );

  Uint8List? _publicKey;
  Uint8List? _secretKey;

  /// Generates and persists a keypair if one doesn't already exist.
  Future<void> ensureIdentityKey() async {
    try {
      await NativeCryptoService.instance.init();

      final existingPub = await _storage.read(key: _publicKeyKey);
      final existingSec = await _storage.read(key: _secretKeyKey);

      if (existingPub != null && existingSec != null) {
        _publicKey = base64Decode(existingPub);
        _secretKey = base64Decode(existingSec);
        Log.i(
          'Identity keypair loaded from secure storage',
          source: LogSource.security,
          component: 'KeyStoreService',
        );
        return;
      }

      final kp = NativeCryptoService.instance.generateEd25519KeyPairRaw();
      _publicKey = kp.publicKey;
      _secretKey = kp.secretKey;

      await _storage.write(
        key: _publicKeyKey,
        value: base64Encode(_publicKey!),
      );
      await _storage.write(
        key: _secretKeyKey,
        value: base64Encode(_secretKey!),
      );

      Log.i(
        'New identity keypair generated and persisted',
        source: LogSource.security,
        component: 'KeyStoreService',
      );
    } catch (e) {
      throw KeyStoreException('Failed to initialise identity key', cause: e);
    }
  }

  /// Returns the base64-encoded Ed25519 public key for this device.
  String get publicKeyBase64 {
    if (_publicKey == null) {
      throw const KeyStoreException('Identity key not yet initialised');
    }
    return base64Encode(_publicKey!);
  }

  /// Returns the raw 32-byte public key.
  Uint8List get publicKeyBytes {
    if (_publicKey == null) {
      throw const KeyStoreException('Identity key not yet initialised');
    }
    return _publicKey!;
  }

  /// Directly sets the keypair — used in tests where FlutterSecureStorage
  /// is unavailable.
  @visibleForTesting
  void initWithKeyPair({
    required Uint8List publicKey,
    required Uint8List secretKey,
  }) {
    _publicKey = publicKey;
    _secretKey = secretKey;
  }

  /// Returns the raw Ed25519 secret key bytes.
  Uint8List get secretKeyBytes {
    if (_secretKey == null) {
      throw const KeyStoreException('Identity key not yet initialised');
    }
    return _secretKey!;
  }

  /// Generates a fresh ephemeral X25519 keypair for session key derivation.
  NativeX25519KeyPair generateEphemeralX25519KeyPair() {
    return NativeCryptoService.instance.generateX25519KeyPairRaw();
  }
}
