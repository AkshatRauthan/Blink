import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/blink_exception.dart';
import '../../core/utils/logger.dart';
import '../native/native_crypto_service.dart';
import 'key_store_service.dart';

/// A QR payload exchanged during the pairing handshake.
class QrPayload {
  final String tokenId;
  final String senderPublicKeyBase64;
  final String x25519PublicKeyBase64;
  final DateTime expiresAt;
  final String signatureBase64;

  const QrPayload({
    required this.tokenId,
    required this.senderPublicKeyBase64,
    required this.x25519PublicKeyBase64,
    required this.expiresAt,
    required this.signatureBase64,
  });

  Map<String, dynamic> toJson() => {
        'id': tokenId,
        'pk': senderPublicKeyBase64,
        'xk': x25519PublicKeyBase64,
        'exp': expiresAt.millisecondsSinceEpoch,
        'sig': signatureBase64,
      };

  factory QrPayload.fromJson(Map<String, dynamic> json) => QrPayload(
        tokenId: json['id'] as String,
        senderPublicKeyBase64: json['pk'] as String,
        x25519PublicKeyBase64: json['xk'] as String,
        expiresAt:
            DateTime.fromMillisecondsSinceEpoch(json['exp'] as int),
        signatureBase64: json['sig'] as String,
      );

  String toQrString() => base64Url.encode(utf8.encode(jsonEncode(toJson())));

  static QrPayload fromQrString(String qrString) {
    final json = jsonDecode(utf8.decode(base64Url.decode(qrString)));
    return QrPayload.fromJson(json as Map<String, dynamic>);
  }

  /// Canonical byte representation of the signed fields.
  static Uint8List signable({
    required String tokenId,
    required String pk,
    required String xk,
    required int expMs,
  }) {
    return Uint8List.fromList(utf8.encode('$tokenId|$pk|$xk|$expMs'));
  }
}

/// Generates and validates single-use, time-limited QR handshake tokens.
///
/// Security properties:
/// - Token contains Ed25519 pubkey + ephemeral X25519 pubkey
/// - Ed25519 detached signature proves token authenticity
/// - TTL: [AppConstants.qrTokenTtl] (5 minutes)
/// - Single-use: token ID recorded after acceptance
class QrHandshakeService {
  QrHandshakeService._();
  static final instance = QrHandshakeService._();

  final _usedTokenIds = <String>{};
  final _localEphemeralSecretsByToken = <String, Uint8List>{};

  /// Generates a new signed QR payload for display.
  QrPayload generateToken() {
    final tokenId = const Uuid().v4();
    final expiresAt = DateTime.now().add(AppConstants.qrTokenTtl);
    final x25519 = NativeCryptoService.instance.generateX25519KeyPairRaw();
    _localEphemeralSecretsByToken[tokenId] = x25519.secretKey;

    final pk = KeyStoreService.instance.publicKeyBase64;
    final xk = base64Encode(x25519.publicKey);
    final expMs = expiresAt.millisecondsSinceEpoch;

    final message = QrPayload.signable(
      tokenId: tokenId,
      pk: pk,
      xk: xk,
      expMs: expMs,
    );

    final signature = NativeCryptoService.instance.signDetached(
      message: message,
      secretKey: KeyStoreService.instance.secretKeyBytes,
    );

    final payload = QrPayload(
      tokenId: tokenId,
      senderPublicKeyBase64: pk,
      x25519PublicKeyBase64: xk,
      expiresAt: expiresAt,
      signatureBase64: base64Encode(signature),
    );

    Log.d(
      'Token generated: $tokenId (expires: $expiresAt)',
      source: LogSource.security,
      component: 'QrHandshakeService',
    );
    return payload;
  }

  /// Validates a scanned QR payload.
  ///
  /// Throws [QrTokenExpiredException] or [QrTokenInvalidException] on failure.
  /// Returns the validated payload on success and marks the token as used.
  QrPayload validateAndConsume(String qrString) {
    final payload = QrPayload.fromQrString(qrString);

    if (DateTime.now().isAfter(payload.expiresAt)) {
      throw const QrTokenExpiredException();
    }
    if (_usedTokenIds.contains(payload.tokenId)) {
      throw const QrTokenInvalidException();
    }

    // Verify Ed25519 signature
    final message = QrPayload.signable(
      tokenId: payload.tokenId,
      pk: payload.senderPublicKeyBase64,
      xk: payload.x25519PublicKeyBase64,
      expMs: payload.expiresAt.millisecondsSinceEpoch,
    );

    final valid = NativeCryptoService.instance.verifyDetached(
      message: message,
      signature: base64Decode(payload.signatureBase64),
      publicKey: base64Decode(payload.senderPublicKeyBase64),
    );

    if (!valid) {
      Log.w(
        'Token ${payload.tokenId} has invalid signature',
        source: LogSource.security,
        component: 'QrHandshakeService',
      );
      throw const QrTokenInvalidException();
    }

    _usedTokenIds.add(payload.tokenId);
    Log.i(
      'Token validated: ${payload.tokenId}',
      source: LogSource.security,
      component: 'QrHandshakeService',
    );
    return payload;
  }

  /// Derives a shared 256-bit session key from the scanned token.
  ///
  /// Call after [validateAndConsume]. Uses our local ephemeral X25519 secret
  /// and the remote's X25519 public key from the token.
  Uint8List deriveSessionKey({
    required String localTokenId,
    required QrPayload remotePayload,
  }) {
    final localSecret = consumeLocalEphemeralSecret(localTokenId);
    final remotePublicKey = base64Decode(remotePayload.x25519PublicKeyBase64);

    return NativeCryptoService.instance.deriveSharedKey(
      localSecretKey: localSecret,
      remotePublicKey: remotePublicKey,
    );
  }

  /// Returns and removes the local ephemeral X25519 secret key for a token.
  Uint8List consumeLocalEphemeralSecret(String tokenId) {
    final key = _localEphemeralSecretsByToken.remove(tokenId);
    if (key == null) {
      throw const QrTokenInvalidException();
    }
    return key;
  }
}
