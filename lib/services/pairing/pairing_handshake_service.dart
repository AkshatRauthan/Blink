import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../native/native_crypto_service.dart';
import '../security/key_store_service.dart';

class PairingHandshakeResult {
  final String remoteDeviceId;
  final Uint8List sessionKey;

  const PairingHandshakeResult({
    required this.remoteDeviceId,
    required this.sessionKey,
  });
}

class PairingHandshakeService {
  PairingHandshakeService._();
  static final instance = PairingHandshakeService._();

  Future<PairingHandshakeResult> establishSessionKey({
    required String remoteIp,
    required int remotePort,
    required String sessionId,
  }) async {
    final x25519 = NativeCryptoService.instance.generateX25519KeyPairRaw();
    final requestBody = jsonEncode({
      'sessionId': sessionId,
      'senderDeviceId': KeyStoreService.instance.publicKeyBase64,
      'senderX25519Pub': base64Encode(x25519.publicKey),
    });

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final port = remotePort > 0 ? remotePort : AppConstants.transferPort;
      final req = await client.post(remoteIp, port, '/pairing/handshake');
      req.headers.contentType = ContentType.json;
      req.write(requestBody);

      final resp = await req.close();
      final respBody = await resp.transform(utf8.decoder).join();
      if (resp.statusCode != HttpStatus.ok) {
        throw Exception('Handshake rejected: $respBody');
      }

      final json = jsonDecode(respBody) as Map<String, dynamic>;
      final remoteDeviceId = json['receiverDeviceId'] as String? ?? '';
      final remotePubB64 = json['receiverX25519Pub'] as String? ?? '';
      if (remotePubB64.isEmpty) {
        throw Exception('Handshake missing receiver key');
      }

      final remotePub = base64Decode(remotePubB64);
      final sessionKey = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: x25519.secretKey,
        remotePublicKey: remotePub,
      );

      Log.i(
        'Handshake complete for $sessionId',
        source: LogSource.security,
        component: 'PairingHandshakeService',
      );

      return PairingHandshakeResult(
        remoteDeviceId: remoteDeviceId,
        sessionKey: sessionKey,
      );
    } catch (e, s) {
      Log.e(
        'Handshake failed',
        source: LogSource.security,
        component: 'PairingHandshakeService',
        error: e,
        stackTrace: s,
      );
      rethrow;
    } finally {
      client.close(force: true);
    }
  }
}
