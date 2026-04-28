import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/device.dart';
import '../../../services/pairing/pairing_handshake_service.dart';

class DevicePairingState {
  final Map<String, Uint8List> sessionKeysByDevice;

  const DevicePairingState({this.sessionKeysByDevice = const {}});

  DevicePairingState copyWith({Map<String, Uint8List>? sessionKeysByDevice}) =>
      DevicePairingState(
        sessionKeysByDevice: sessionKeysByDevice ?? this.sessionKeysByDevice,
      );
}

class DevicePairingNotifier extends Notifier<DevicePairingState> {
  @override
  DevicePairingState build() => const DevicePairingState();

  Future<Uint8List> pairWithDevice(
    Device device, {
    required String sessionId,
  }) async {
    final remoteIp = device.lastKnownIp ?? '';
    if (remoteIp.isEmpty) {
      throw Exception('Missing remote IP for pairing');
    }

    final result = await PairingHandshakeService.instance.establishSessionKey(
      remoteIp: remoteIp,
      remotePort: device.lastKnownPort ?? 0,
      sessionId: sessionId,
    );
    final sessionKey = result.sessionKey;
    final next = Map<String, Uint8List>.from(state.sessionKeysByDevice);
    next[device.deviceId] = sessionKey;
    state = state.copyWith(sessionKeysByDevice: next);
    return sessionKey;
  }

  Uint8List? getSessionKey(String deviceId) =>
      state.sessionKeysByDevice[deviceId];

  void clearPairing(String deviceId) {
    if (!state.sessionKeysByDevice.containsKey(deviceId)) return;
    final next = Map<String, Uint8List>.from(state.sessionKeysByDevice);
    next.remove(deviceId);
    state = state.copyWith(sessionKeysByDevice: next);
  }

  void clearAll() {
    state = const DevicePairingState();
  }
}

final devicePairingProvider =
    NotifierProvider<DevicePairingNotifier, DevicePairingState>(
  DevicePairingNotifier.new,
);
