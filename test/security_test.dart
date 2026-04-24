import 'dart:convert';
import 'dart:typed_data';

import 'package:blink/core/errors/blink_exception.dart';
import 'package:blink/services/native/native_crypto_service.dart';
import 'package:blink/services/security/key_store_service.dart';
import 'package:blink/services/security/qr_handshake_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await NativeCryptoService.instance.init();

    // Generate a test identity keypair and inject into KeyStoreService
    final kp = NativeCryptoService.instance.generateEd25519KeyPairRaw();
    KeyStoreService.instance.initWithKeyPair(
      publicKey: kp.publicKey,
      secretKey: kp.secretKey,
    );
  });

  group('Ed25519 signatures', () {
    test('sign and verify round-trip', () {
      final kp = NativeCryptoService.instance.generateEd25519KeyPairRaw();
      final message = Uint8List.fromList([1, 2, 3, 4, 5]);

      final sig = NativeCryptoService.instance.signDetached(
        message: message,
        secretKey: kp.secretKey,
      );

      expect(sig.length, equals(64));
      expect(
        NativeCryptoService.instance.verifyDetached(
          message: message,
          signature: sig,
          publicKey: kp.publicKey,
        ),
        isTrue,
      );
    });

    test('tampered message fails verification', () {
      final kp = NativeCryptoService.instance.generateEd25519KeyPairRaw();
      final message = Uint8List.fromList([1, 2, 3]);
      final sig = NativeCryptoService.instance.signDetached(
        message: message,
        secretKey: kp.secretKey,
      );

      final tampered = Uint8List.fromList([1, 2, 4]);
      expect(
        NativeCryptoService.instance.verifyDetached(
          message: tampered,
          signature: sig,
          publicKey: kp.publicKey,
        ),
        isFalse,
      );
    });

    test('wrong key fails verification', () {
      final kp1 = NativeCryptoService.instance.generateEd25519KeyPairRaw();
      final kp2 = NativeCryptoService.instance.generateEd25519KeyPairRaw();
      final message = Uint8List.fromList([10, 20, 30]);
      final sig = NativeCryptoService.instance.signDetached(
        message: message,
        secretKey: kp1.secretKey,
      );

      expect(
        NativeCryptoService.instance.verifyDetached(
          message: message,
          signature: sig,
          publicKey: kp2.publicKey,
        ),
        isFalse,
      );
    });
  });

  group('QR handshake', () {
    test('generateToken produces a valid signed payload', () {
      final token = QrHandshakeService.instance.generateToken();

      expect(token.tokenId, isNotEmpty);
      expect(token.senderPublicKeyBase64, isNotEmpty);
      expect(token.x25519PublicKeyBase64, isNotEmpty);
      expect(token.signatureBase64, isNotEmpty);
      expect(token.expiresAt.isAfter(DateTime.now()), isTrue);
    });

    test('QR encode/decode round-trip preserves payload', () {
      final token = QrHandshakeService.instance.generateToken();
      final qrString = token.toQrString();
      final decoded = QrPayload.fromQrString(qrString);

      expect(decoded.tokenId, equals(token.tokenId));
      expect(decoded.senderPublicKeyBase64,
          equals(token.senderPublicKeyBase64));
      expect(decoded.x25519PublicKeyBase64,
          equals(token.x25519PublicKeyBase64));
      expect(decoded.expiresAt.millisecondsSinceEpoch,
          equals(token.expiresAt.millisecondsSinceEpoch));
      expect(decoded.signatureBase64, equals(token.signatureBase64));
    });

    test('validateAndConsume accepts a valid token', () {
      final token = QrHandshakeService.instance.generateToken();
      final qrString = token.toQrString();

      final validated = QrHandshakeService.instance.validateAndConsume(qrString);
      expect(validated.tokenId, equals(token.tokenId));
    });

    test('token is single-use — second validation throws', () {
      final token = QrHandshakeService.instance.generateToken();
      final qrString = token.toQrString();

      QrHandshakeService.instance.validateAndConsume(qrString);
      expect(
        () => QrHandshakeService.instance.validateAndConsume(qrString),
        throwsA(isA<QrTokenInvalidException>()),
      );
    });

    test('tampered token is rejected', () {
      final token = QrHandshakeService.instance.generateToken();
      // Modify the payload after signing
      final tampered = QrPayload(
        tokenId: token.tokenId,
        senderPublicKeyBase64: token.senderPublicKeyBase64,
        x25519PublicKeyBase64: token.x25519PublicKeyBase64,
        expiresAt: token.expiresAt.add(const Duration(hours: 1)),
        signatureBase64: token.signatureBase64,
      );

      expect(
        () => QrHandshakeService.instance
            .validateAndConsume(tampered.toQrString()),
        throwsA(isA<QrTokenInvalidException>()),
      );
    });
  });

  group('X25519 session key derivation', () {
    test('both sides derive the same shared secret', () {
      final kpA = NativeCryptoService.instance.generateX25519KeyPairRaw();
      final kpB = NativeCryptoService.instance.generateX25519KeyPairRaw();

      final sharedA = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: kpA.secretKey,
        remotePublicKey: kpB.publicKey,
      );
      final sharedB = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: kpB.secretKey,
        remotePublicKey: kpA.publicKey,
      );

      expect(sharedA, equals(sharedB));
      expect(sharedA.length, equals(32));
    });

    test('different keypairs produce different shared secrets', () {
      final kpA = NativeCryptoService.instance.generateX25519KeyPairRaw();
      final kpB = NativeCryptoService.instance.generateX25519KeyPairRaw();
      final kpC = NativeCryptoService.instance.generateX25519KeyPairRaw();

      final sharedAB = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: kpA.secretKey,
        remotePublicKey: kpB.publicKey,
      );
      final sharedAC = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: kpA.secretKey,
        remotePublicKey: kpC.publicKey,
      );

      expect(sharedAB, isNot(equals(sharedAC)));
    });

    test('full QR handshake: generate, validate, derive shared key', () {
      // Simulate device A generating a QR token
      final tokenA = QrHandshakeService.instance.generateToken();
      final qrString = tokenA.toQrString();

      // Simulate device B scanning and validating
      final validatedA =
          QrHandshakeService.instance.validateAndConsume(qrString);

      // Device B generates its own X25519 keypair
      final kpB = NativeCryptoService.instance.generateX25519KeyPairRaw();

      // Device B derives shared key using A's X25519 public key
      final sharedB = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: kpB.secretKey,
        remotePublicKey: base64Decode(validatedA.x25519PublicKeyBase64),
      );

      // Device A derives shared key using B's X25519 public key
      final localSecretA = QrHandshakeService.instance
          .consumeLocalEphemeralSecret(tokenA.tokenId);
      final sharedA = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: localSecretA,
        remotePublicKey: kpB.publicKey,
      );

      // Both sides should have the same 256-bit session key
      expect(sharedA, equals(sharedB));
      expect(sharedA.length, equals(32));

      // Session key should be usable for encryption
      final testData = Uint8List.fromList([42, 43, 44, 45]);
      final nonce = NativeCryptoService.instance.generateNonce();
      final encrypted = NativeCryptoService.instance.encrypt(
        plaintext: testData,
        key: sharedA,
        nonce: nonce,
      );
      final decrypted = NativeCryptoService.instance.decrypt(
        ciphertext: encrypted,
        key: sharedB,
        nonce: nonce,
      );
      expect(decrypted, equals(testData));
    });
  });
}
