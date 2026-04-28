import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/transfer_session.dart';
import '../../chat/providers/chat_provider.dart';
import '../../../services/transfer/transfer_manager.dart';
import '../../../services/transfer/http_server_service.dart';
import '../../../core/constants/app_constants.dart';

/// Live list of currently active (non-terminal) transfer sessions.
///
/// Rebuilds whenever TransferManager emits a progress update.
/// Also starts the receiver HTTP server on first build.
class ActiveTransfersNotifier extends Notifier<List<TransferSession>> {
  StreamSubscription<TransferSession>? _sub;
  final _openedChatSessions = <String>{};

  @override
  List<TransferSession> build() {
    _ensureReceiver();
    _sub?.cancel();
    _sub = TransferManager.instance.onProgress.listen((_) {
      state = TransferManager.instance.activeSessions;
      _syncChatSessions(state);
    });
    ref.onDispose(() => _sub?.cancel());
    final sessions = TransferManager.instance.activeSessions;
    _syncChatSessions(sessions);
    return sessions;
  }

  Future<void> _ensureReceiver() async {
    await TransferManager.instance.startReceiver();
  }

  void _syncChatSessions(List<TransferSession> sessions) {
    for (final session in sessions) {
      if (session.direction != TransferDirection.receive) continue;
      if (_openedChatSessions.contains(session.sessionId)) continue;
      final remoteIp =
          HttpServerService.instance.remoteIpForSession(session.sessionId);
      if (remoteIp == null || remoteIp.isEmpty) continue;
      ref.read(chatNotifierProvider.notifier).openSession(
            sessionId: session.sessionId,
            remoteIp: remoteIp,
            remotePort: AppConstants.transferPort,
          );
      _openedChatSessions.add(session.sessionId);
    }
  }

  void acceptTransfer(String sessionId) {
    TransferManager.instance.acceptTransfer(sessionId);
  }

  Future<void> declineTransfer(String sessionId) async {
    await TransferManager.instance.declineTransfer(sessionId);
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
    String? sessionId,
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
        sessionId: sessionId,
      );

      ref.read(chatNotifierProvider.notifier).openSession(
            sessionId: session.sessionId,
            remoteIp: remoteIp,
            remotePort: remotePort,
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
