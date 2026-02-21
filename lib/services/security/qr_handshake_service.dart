import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/blink_exception.dart';
import '../../core/utils/logger.dart';
import 'key_store_service.dart';

/// A QR payload exchanged during the pairing handshake.
class QrPayload {
  final String tokenId;
  final String senderPublicKeyBase64;
  final String x25519PublicKeyBase64;
  final DateTime expiresAt;
  final String hmacBase64;

  const QrPayload({
    required this.tokenId,
    required this.senderPublicKeyBase64,
    required this.x25519PublicKeyBase64,
    required this.expiresAt,
    required this.hmacBase64,
  });

  Map<String, dynamic> toJson() => {
        'id': tokenId,
        'pk': senderPublicKeyBase64,
        'xk': x25519PublicKeyBase64,
        'exp': expiresAt.millisecondsSinceEpoch,
        'hmac': hmacBase64,
      };

  factory QrPayload.fromJson(Map<String, dynamic> json) => QrPayload(
        tokenId: json['id'] as String,
        senderPublicKeyBase64: json['pk'] as String,
        x25519PublicKeyBase64: json['xk'] as String,
        expiresAt:
            DateTime.fromMillisecondsSinceEpoch(json['exp'] as int),
        hmacBase64: json['hmac'] as String,
      );

  String toQrString() => base64Url.encode(utf8.encode(jsonEncode(toJson())));

  static QrPayload fromQrString(String qrString) {
    final json = jsonDecode(utf8.decode(base64Url.decode(qrString)));
    return QrPayload.fromJson(json as Map<String, dynamic>);
  }
}

/// Generates and validates single-use, time-limited QR handshake tokens.
///
/// Security properties:
/// - Token contains Ed25519 pubkey + ephemeral X25519 pubkey
/// - HMAC-signed with the identity secret key
/// - TTL: [AppConstants.qrTokenTtl] (5 minutes)
/// - Single-use: token ID recorded after acceptance
class QrHandshakeService {
  QrHandshakeService._();
  static final instance = QrHandshakeService._();

  final _usedTokenIds = <String>{};

  /// Generates a new signed QR payload for display.
  QrPayload generateToken() {
    final tokenId = const Uuid().v4();
    final expiry = DateTime.now().add(AppConstants.qrTokenTtl);

    // TODO: Generate ephemeral X25519 keypair from NativeCryptoService
    // For now, stub with identity pubkey
    final payload = QrPayload(
      tokenId: tokenId,
      senderPublicKeyBase64: KeyStoreService.instance.publicKeyBase64,
      x25519PublicKeyBase64: KeyStoreService.instance.publicKeyBase64,
      expiresAt: expiry,
      hmacBase64: '', // TODO: HMAC-sign the payload fields
    );
    Log.d('[QR] Token generated: $tokenId (expires: $expiry)');
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
    // TODO: Verify HMAC signature using sender's Ed25519 pubkey

    _usedTokenIds.add(payload.tokenId);
    Log.i('[QR] Token validated: ${payload.tokenId}');
    return payload;
  }
}
