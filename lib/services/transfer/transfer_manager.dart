import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/transfer_session.dart';
import '../../data/models/transfer_file.dart';
import '../../data/repositories/transfer_repository.dart';
import 'http_server_service.dart';
import 'transfer_isolate.dart';

/// Orchestrates multi-file transfer sessions.
///
/// Sender side: spawns Dart Isolates for file streaming.
/// Receiver side: starts [HttpServerService] and listens for incoming chunks.
///
/// Exposes [onProgress] for UI consumption via TransferNotifier.
class TransferManager {
  TransferManager._();
  static final instance = TransferManager._();

  final _repo = TransferRepository.instance;
  final _isolates = <String, Isolate>{};
  final _receivePorts = <String, ReceivePort>{};

  final _progressController = StreamController<TransferSession>.broadcast();
  final _sessions = <String, TransferSession>{};
  final _sessionFiles = <String, List<TransferFile>>{};

  /// Stream of session updates (state changes, progress).
  Stream<TransferSession> get onProgress => _progressController.stream;

  /// Returns a snapshot of all tracked sessions.
  List<TransferSession> get activeSessions => _sessions.values.toList();

  /// Returns files for a given session.
  List<TransferFile> filesForSession(String sessionId) =>
      _sessionFiles[sessionId] ?? [];

  // ── Sender ────────────────────────────────────────────────────────────────

  /// Starts sending [files] to [remoteIp]:[remotePort].
  Future<TransferSession> sendFiles({
    required List<File> files,
    required String remoteDeviceId,
    required String remoteIp,
    required int remotePort,
    required Uint8List sessionKey,
  }) async {
    final sessionId = const Uuid().v4();

    final transferFiles = <TransferFile>[];
    for (final f in files) {
      transferFiles.add(
        TransferFile(
          fileId: const Uuid().v4(),
          sessionId: sessionId,
          fileName: f.uri.pathSegments.last,
          mimeType: FileUtils.mimeType(f.path),
          sizeBytes: f.lengthSync(),
        ),
      );
    }

    final totalBytes = transferFiles.fold<int>(0, (sum, f) => sum + f.sizeBytes);

    final session = TransferSession(
      sessionId: sessionId,
      remoteDeviceId: remoteDeviceId,
      direction: TransferDirection.send,
      status: TransferStatus.connecting,
      totalBytes: totalBytes,
      startedAt: DateTime.now(),
    );

    _sessions[sessionId] = session;
    _sessionFiles[sessionId] = transferFiles;

    await _repo.saveSession(session);
    for (final tf in transferFiles) {
      await _repo.saveFile(tf);
    }

    _progressController.add(session);

    // Spawn transfer isolate
    await _spawnSenderIsolate(
      sessionId: sessionId,
      files: files,
      fileIds: transferFiles.map((f) => f.fileId).toList(),
      sessionKey: sessionKey,
      remoteIp: remoteIp,
      remotePort: remotePort,
    );

    Log.i(
      'Send session $sessionId started (${files.length} files, ${_formatBytes(totalBytes)})',
      source: LogSource.process,
      component: 'TransferManager',
    );

    return session;
  }

  Future<void> _spawnSenderIsolate({
    required String sessionId,
    required List<File> files,
    required List<String> fileIds,
    required Uint8List sessionKey,
    required String remoteIp,
    required int remotePort,
  }) async {
    final receivePort = ReceivePort();
    final args = TransferIsolateArgs(
      sessionId: sessionId,
      filePaths: files.map((f) => f.path).toList(),
      fileIds: fileIds,
      sessionKey: sessionKey,
      remoteIp: remoteIp,
      remotePort: remotePort,
      progressPort: receivePort.sendPort,
    );

    final isolate = await Isolate.spawn(transferIsolateMain, args);
    _isolates[sessionId] = isolate;
    _receivePorts[sessionId] = receivePort;

    receivePort.listen((message) {
      if (message is TransferProgress) {
        _handleSenderProgress(message);
      }
    });
  }

  void _handleSenderProgress(TransferProgress progress) {
    final session = _sessions[progress.sessionId];
    if (session == null) return;

    // Update file-level progress
    final files = _sessionFiles[progress.sessionId];
    if (files != null && progress.fileIndex < files.length) {
      files[progress.fileIndex] = files[progress.fileIndex].copyWith(
        transferredBytes: progress.bytesTransferred,
        completed: progress.fileComplete,
      );
    }

    // Handle errors
    if (progress.error != null) {
      final failed = session.copyWith(
        status: TransferStatus.failed,
        failureReason: progress.error,
      );
      _sessions[progress.sessionId] = failed;
      _progressController.add(failed);
      _cleanupIsolate(progress.sessionId);

      Log.e(
        'Session ${progress.sessionId} failed: ${progress.error}',
        source: LogSource.process,
        component: 'TransferManager',
      );
      return;
    }

    // Calculate aggregate progress
    final totalTransferred = files?.fold<int>(
            0, (sum, f) => sum + f.transferredBytes) ??
        0;

    TransferStatus newStatus;
    if (progress.sessionComplete) {
      newStatus = TransferStatus.completed;
    } else if (progress.fileComplete || totalTransferred > 0) {
      newStatus = TransferStatus.transferring;
    } else {
      newStatus = session.status;
    }

    final updated = session.copyWith(
      status: newStatus,
      transferredBytes: totalTransferred,
      completedAt:
          progress.sessionComplete ? DateTime.now() : null,
    );

    _sessions[progress.sessionId] = updated;
    _progressController.add(updated);

    if (progress.sessionComplete) {
      _cleanupIsolate(progress.sessionId);
      Log.i(
        'Session ${progress.sessionId} completed',
        source: LogSource.process,
        component: 'TransferManager',
      );
    }

    // Persist progress periodically
    _repo.saveSession(updated);
  }

  // ── Receiver ──────────────────────────────────────────────────────────────

  /// Starts the receiver HTTP server and listens for incoming transfers.
  Future<void> startReceiver() async {
    final server = HttpServerService.instance;
    if (server.isRunning) return;
    await server.start();

    server.onSessionBegin.listen(_handleIncomingBegin);
    server.onChunk.listen(_handleReceiverChunk);

    Log.i(
      'Receiver started on port ${AppConstants.transferPort}',
      source: LogSource.process,
      component: 'TransferManager',
    );
  }

  void _handleIncomingBegin(SessionBeginEvent event) {
    if (_sessions.containsKey(event.sessionId)) return;

    final session = TransferSession(
      sessionId: event.sessionId,
      remoteDeviceId: event.senderDeviceId,
      direction: TransferDirection.receive,
      status: TransferStatus.pending,
      totalBytes: event.totalBytes,
      startedAt: DateTime.now(),
    );

    _sessions[event.sessionId] = session;
    _progressController.add(session);

    Log.i(
      'Incoming transfer ${event.sessionId}: ${event.fileCount} files, '
      '${_formatBytes(event.totalBytes)} from ${event.senderDeviceId}',
      source: LogSource.process,
      component: 'TransferManager',
    );
  }

  void _handleReceiverChunk(ChunkEvent event) {
    var session = _sessions[event.sessionId];

    if (session == null) {
      session = TransferSession(
        sessionId: event.sessionId,
        remoteDeviceId: '',
        direction: TransferDirection.receive,
        status: TransferStatus.transferring,
        totalBytes: event.totalBytes,
        startedAt: DateTime.now(),
      );
      _sessions[event.sessionId] = session;
    }

    if (session.status == TransferStatus.cancelled) return;

    TransferStatus newStatus;
    if (event.sessionComplete) {
      newStatus = TransferStatus.completed;
    } else if (session.status == TransferStatus.pending) {
      newStatus = TransferStatus.pending;
    } else {
      newStatus = TransferStatus.transferring;
    }

    final updated = session.copyWith(
      status: newStatus,
      transferredBytes: event.receivedBytes,
      completedAt: event.sessionComplete ? DateTime.now() : null,
    );

    _sessions[event.sessionId] = updated;
    _progressController.add(updated);
  }

  /// Accepts an incoming pending transfer (transitions to transferring).
  void acceptTransfer(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null || session.status != TransferStatus.pending) return;

    final updated = session.copyWith(status: TransferStatus.transferring);
    _sessions[sessionId] = updated;
    _progressController.add(updated);
    _repo.saveSession(updated);

    Log.i(
      'Session $sessionId accepted',
      source: LogSource.process,
      component: 'TransferManager',
    );
  }

  /// Declines an incoming transfer (cancels and deletes received files).
  Future<void> declineTransfer(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final cancelled = session.copyWith(status: TransferStatus.cancelled);
    _sessions[sessionId] = cancelled;
    _progressController.add(cancelled);

    await HttpServerService.instance.cancelSession(sessionId);
    await _repo.saveSession(cancelled);

    Log.i(
      'Session $sessionId declined',
      source: LogSource.process,
      component: 'TransferManager',
    );
  }

  /// Stops the receiver HTTP server.
  Future<void> stopReceiver() async {
    await HttpServerService.instance.stop();
  }

  // ── Session Control ───────────────────────────────────────────────────────

  /// Cancels a transfer session.
  Future<void> cancelTransfer(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    _cleanupIsolate(sessionId);

    final cancelled = session.copyWith(status: TransferStatus.cancelled);
    _sessions[sessionId] = cancelled;
    _progressController.add(cancelled);
    await _repo.saveSession(cancelled);

    Log.i(
      'Session $sessionId cancelled',
      source: LogSource.process,
      component: 'TransferManager',
    );
  }

  void _cleanupIsolate(String sessionId) {
    _isolates[sessionId]?.kill(priority: Isolate.beforeNextEvent);
    _isolates.remove(sessionId);
    _receivePorts[sessionId]?.close();
    _receivePorts.remove(sessionId);
  }

  /// Cleans up all resources.
  Future<void> dispose() async {
    for (final id in _isolates.keys.toList()) {
      _cleanupIsolate(id);
    }
    await _progressController.close();
    await stopReceiver();
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
