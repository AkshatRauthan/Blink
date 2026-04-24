import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/transfer_session.dart';
import '../../../services/transfer/transfer_manager.dart';

/// Live list of currently active (non-terminal) transfer sessions.
///
/// Rebuilds whenever TransferManager emits a progress update.
class ActiveTransfersNotifier extends Notifier<List<TransferSession>> {
  StreamSubscription<TransferSession>? _sub;

  @override
  List<TransferSession> build() {
    _sub?.cancel();
    _sub = TransferManager.instance.onProgress.listen((_) {
      state = TransferManager.instance.activeSessions;
    });
    ref.onDispose(() => _sub?.cancel());
    return TransferManager.instance.activeSessions;
  }
}

final activeTransfersProvider =
    NotifierProvider<ActiveTransfersNotifier, List<TransferSession>>(
  ActiveTransfersNotifier.new,
);

/// Drives the send flow: start a transfer to a specific device.
class TransferNotifier extends Notifier<AsyncValue<TransferSession?>> {
  @override
  AsyncValue<TransferSession?> build() => const AsyncData(null);

  Future<void> startSend({
    required List<String> filePaths,
    required String remoteDeviceId,
    required String remoteIp,
    required int remotePort,
    required Uint8List sessionKey,
  }) async {
    state = const AsyncLoading();
    try {
      final files = filePaths.map((p) => File(p)).toList();

      final session = await TransferManager.instance.sendFiles(
        files: files,
        remoteDeviceId: remoteDeviceId,
        remoteIp: remoteIp,
        remotePort: remotePort,
        sessionKey: sessionKey,
      );

      state = AsyncData(session);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> cancel(String sessionId) async {
    await TransferManager.instance.cancelTransfer(sessionId);
  }
}

final transferNotifierProvider =
    NotifierProvider<TransferNotifier, AsyncValue<TransferSession?>>(
  TransferNotifier.new,
);
