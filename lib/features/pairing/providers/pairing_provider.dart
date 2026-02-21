import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/security/qr_handshake_service.dart';
import '../../../core/utils/logger.dart';

class PairingNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() {
    // Generate a QR token immediately on screen open
    _generateToken();
    return const AsyncData(null);
  }

  void _generateToken() {
    try {
      final payload = QrHandshakeService.instance.generateToken();
      state = AsyncData(payload.toQrString());
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// Called when the scanner decodes a QR code string.
  Future<void> handleScannedQr(String qrString) async {
    state = const AsyncLoading();
    try {
      final payload = QrHandshakeService.instance.validateAndConsume(qrString);
      // TODO: Derive session key from payload.x25519PublicKeyBase64
      // TODO: Open transfer session with paired device
      Log.i('[Pairing] Paired with device: ${payload.senderPublicKeyBase64.substring(0, 8)}…');
      state = AsyncData(qrString);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  void regenerate() => _generateToken();
}

final pairingNotifierProvider =
    NotifierProvider<PairingNotifier, AsyncValue<String?>>(
  PairingNotifier.new,
);
