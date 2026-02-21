import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/transfer_session.dart';

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
      // TODO: Get session key from CryptoService / PairingNotifier
      // final session = await TransferManager.instance.sendFiles(...)
      state = const AsyncData(null);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final transferNotifierProvider =
    NotifierProvider<TransferNotifier, AsyncValue<TransferSession?>>(
  TransferNotifier.new,
);
