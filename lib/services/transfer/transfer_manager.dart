// ignore_for_file: unused_field
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/transfer_session.dart';
import '../../data/models/transfer_file.dart';
import '../../data/repositories/transfer_repository.dart';
import '../native/native_hash_service.dart';
import 'transfer_isolate.dart';

/// Orchestrates multi-file transfer sessions.
///
/// Spawns one Dart Isolate per active file to keep disk I/O and encryption
/// off the main thread. Caps parallelism at [AppConstants.maxConcurrentTransfers].
class TransferManager {
  TransferManager._();
  static final instance = TransferManager._();

  final _repo = TransferRepository.instance;
  final _active = <String, Isolate>{};

  /// Starts sending [files] to [remoteIp]:[remotePort].
  /// Returns the created [TransferSession].
  Future<TransferSession> sendFiles({
    required List<File> files,
    required String remoteDeviceId,
    required String remoteIp,
    required int remotePort,
    required Uint8List sessionKey,
  }) async {
    final sessionId = const Uuid().v4();
    await NativeHashService.instance.init();

    final transferFiles = <TransferFile>[];
    for (final f in files) {
      final checksum = await NativeHashService.instance.hashFileHex(f);
      transferFiles.add(
        TransferFile(
          fileId: const Uuid().v4(),
          sessionId: sessionId,
          fileName: f.uri.pathSegments.last,
          mimeType: FileUtils.mimeType(f.path),
          sizeBytes: f.lengthSync(),
          blake3Checksum: checksum,
        ),
      );
    }

    final session = TransferSession(
      sessionId: sessionId,
      remoteDeviceId: remoteDeviceId,
      direction: TransferDirection.send,
      status: TransferStatus.connecting,
      totalBytes: transferFiles.fold(0, (sum, f) => sum + f.sizeBytes),
      startedAt: DateTime.now(),
    );

    await _repo.saveSession(session);
    for (final tf in transferFiles) {
      await _repo.saveFile(tf);
    }

    // Spawn up to maxConcurrentTransfers isolates
    final chunks = _partition(files, AppConstants.maxConcurrentTransfers);
    for (final chunk in chunks) {
      await _spawnTransferIsolate(
        sessionId: sessionId,
        files: chunk,
        sessionKey: sessionKey,
        remoteIp: remoteIp,
        remotePort: remotePort,
      );
    }

    Log.i(
      '[TransferManager] Session $sessionId started (${files.length} files)',
    );
    return session;
  }

  Future<void> _spawnTransferIsolate({
    required String sessionId,
    required List<File> files,
    required Uint8List sessionKey,
    required String remoteIp,
    required int remotePort,
  }) async {
    Log.d('[TransferManager] Spawning isolate for ${files.length} files');

    final receivePort = ReceivePort();
    final args = TransferIsolateArgs(
      sessionId: sessionId,
      filePaths: files.map((f) => f.path).toList(),
      sessionKey: sessionKey,
      remoteIp: remoteIp,
      remotePort: remotePort,
      progressPort: receivePort.sendPort,
    );

    final isolate = await Isolate.spawn(transferIsolateMain, args);
    _active[sessionId] = isolate;

    receivePort.listen((message) {
      if (message is TransferProgress) {
        if (message.error != null) {
          Log.e(
            '[TransferManager] Error in session ${message.sessionId}: ${message.error}',
          );
          _active.remove(message.sessionId)?.kill();
          receivePort.close();
          return;
        }

        Log.d(
          '[TransferManager] Progress ${message.sessionId}: ${message.bytesTransferred} / ${message.totalBytes} bytes',
        );

        if (message.completed) {
          Log.i('[TransferManager] Transfer complete for ${message.filePath}');
          // Remove isolate cleanup logic happens after all files finish
          // Here we could keep count of completed files per session and then kill
        }
      }
    });
  }

  /// Partitions [list] into sublists of maximum [size].
  List<List<T>> _partition<T>(List<T> list, int size) {
    final result = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      result.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return result;
  }
}
