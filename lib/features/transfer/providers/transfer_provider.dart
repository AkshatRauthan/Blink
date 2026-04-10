import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/transfer_session.dart';
import '../../../services/transfer/transfer_manager.dart';
import '../../../services/security/key_store_service.dart';

/// List of currently active (non-terminal) transfer sessions.
final activeTransfersProvider = Provider<List<TransferSession>>((ref) {
  // TODO: Return sessions from TransferManager keyed by sessionId
  return [];
});

/// Riverpod notifier that drives the send flow.
class TransferNotifier extends Notifier<AsyncValue<TransferSession?>> {
  @override
  AsyncValue<TransferSession?> build() => const AsyncData(null);

  Future<void> startSend({
    required List<String> filePaths,
    required String remoteDeviceId,
    required String remoteIp,
    required int remotePort,
  }) async {
    state = const AsyncLoading();
    try {
      // Temporary fallback until QR integration (Phase 2)
      final kp = await KeyStoreService.instance.getIdentityKeyPair();
      final dummyKey = kp!.secretKey.sublist(0, 32);

      final files = filePaths.map((p) => File(p)).toList();

      final session = await TransferManager.instance.sendFiles(
        files: files,
        remoteDeviceId: remoteDeviceId,
        remoteIp: remoteIp,
        remotePort: remotePort,
        sessionKey: dummyKey,
      );

      state = AsyncData(session);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final transferNotifierProvider =
    NotifierProvider<TransferNotifier, AsyncValue<TransferSession?>>(
  TransferNotifier.new,
);
