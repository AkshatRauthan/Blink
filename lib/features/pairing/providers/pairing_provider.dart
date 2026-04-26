import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../../services/native/native_crypto_service.dart';
import '../../../services/security/qr_handshake_service.dart';

class PairingResult {
  final String remotePublicKeyBase64;
  final Uint8List sessionKey;

  const PairingResult({
    required this.remotePublicKeyBase64,
    required this.sessionKey,
  });
}

class PairingState {
  final String? qrString;
  final PairingResult? lastPairing;
  final String? error;
  final bool isLoading;

  const PairingState({
    this.qrString,
    this.lastPairing,
    this.error,
    this.isLoading = false,
  });

  PairingState copyWith({
    String? qrString,
    PairingResult? lastPairing,
    bool clearLastPairing = false,
    String? error,
    bool clearError = false,
    bool? isLoading,
  }) =>
      PairingState(
        qrString: qrString ?? this.qrString,
        lastPairing:
            clearLastPairing ? null : (lastPairing ?? this.lastPairing),
        error: clearError ? null : (error ?? this.error),
        isLoading: isLoading ?? this.isLoading,
      );
}

class PairingNotifier extends Notifier<PairingState> {
  @override
  PairingState build() {
    _generateToken();
    return const PairingState();
  }

  void _generateToken() {
    try {
      final payload = QrHandshakeService.instance.generateToken();
      state = state.copyWith(
        qrString: payload.toQrString(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to generate QR token');
    }
  }

  Future<PairingResult?> handleScannedQr(String qrString) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final payload =
          QrHandshakeService.instance.validateAndConsume(qrString);

      final localX25519 =
          NativeCryptoService.instance.generateX25519KeyPairRaw();
      final sessionKey = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: localX25519.secretKey,
        remotePublicKey: base64Decode(payload.x25519PublicKeyBase64),
      );

      final result = PairingResult(
        remotePublicKeyBase64: payload.senderPublicKeyBase64,
        sessionKey: sessionKey,
      );

      Log.i(
        'Paired with device ${payload.senderPublicKeyBase64.substring(0, 8)}... '
        'session key derived via X25519 ECDH',
        source: LogSource.security,
        component: 'PairingNotifier',
      );

      state = state.copyWith(
        lastPairing: result,
        isLoading: false,
      );

      return result;
    } catch (e, s) {
      Log.e(
        'QR pairing failed',
        source: LogSource.security,
        component: 'PairingNotifier',
        error: e,
        stackTrace: s,
      );
      state = state.copyWith(
        error: _friendlyError(e),
        isLoading: false,
      );
      return null;
    }
  }

  void regenerate() => _generateToken();

  void clearError() => state = state.copyWith(clearError: true);

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Expired')) return 'QR code has expired';
    if (msg.contains('Invalid')) return 'Invalid or already used QR code';
    return 'Pairing failed';
  }
}

final pairingNotifierProvider =
    NotifierProvider<PairingNotifier, PairingState>(PairingNotifier.new);
