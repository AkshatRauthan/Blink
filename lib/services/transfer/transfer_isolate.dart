import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../../core/constants/app_constants.dart';
import '../transfer/http_client_service.dart';

/// Arguments passed to the transfer isolate.
class TransferIsolateArgs {
  final String sessionId;
  final List<String> filePaths;
  final Uint8List sessionKey;
  final String remoteIp;
  final int remotePort;
  final SendPort progressPort;

  const TransferIsolateArgs({
    required this.sessionId,
    required this.filePaths,
    required this.sessionKey,
    required this.remoteIp,
    required this.remotePort,
    required this.progressPort,
  });
}

/// Progress update sent back to the main isolate.
class TransferProgress {
  final String sessionId;
  final String filePath;
  final int bytesTransferred;
  final int totalBytes;
  final bool completed;
  final String? error;

  const TransferProgress({
    required this.sessionId,
    required this.filePath,
    required this.bytesTransferred,
    required this.totalBytes,
    this.completed = false,
    this.error,
  });
}

/// Entry point for the file-transfer Dart Isolate.
///
/// Reads each file in [args.filePaths] as a stream of 4 MB chunks,
/// encrypts each chunk via AES-256-GCM (libsodium), and sends it via HTTP.
///
/// Runs entirely off the main thread — I/O and crypto never block the UI.
Future<void> transferIsolateMain(TransferIsolateArgs args) async {
  final client = HttpClientService.instance;
  final chunkSize = AppConstants.chunkSizeBytes;

  for (final filePath in args.filePaths) {
    final file = File(filePath);
    final totalBytes = await file.length();
    int transferred = 0;
    int chunkIndex = 0;

    final stream = file.openRead();
    final buffer = <int>[];

    await for (final chunk in stream) {
      buffer.addAll(chunk);

      while (buffer.length >= chunkSize) {
        final toSend = Uint8List.fromList(buffer.sublist(0, chunkSize));
        buffer.removeRange(0, chunkSize);

        final ok = await client.sendChunk(
          remoteIp: args.remoteIp,
          remotePort: args.remotePort,
          sessionId: args.sessionId,
          sessionKey: args.sessionKey,
          plainChunk: toSend,
          chunkIndex: chunkIndex++,
        );

        if (!ok) {
          args.progressPort.send(TransferProgress(
            sessionId: args.sessionId,
            filePath: filePath,
            bytesTransferred: transferred,
            totalBytes: totalBytes,
            error: 'Chunk $chunkIndex failed',
          ));
          return;
        }

        transferred += toSend.length;
        args.progressPort.send(TransferProgress(
          sessionId: args.sessionId,
          filePath: filePath,
          bytesTransferred: transferred,
          totalBytes: totalBytes,
        ));
      }
    }

    // Send remaining bytes in final partial chunk
    if (buffer.isNotEmpty) {
      final toSend = Uint8List.fromList(buffer);
      await client.sendChunk(
        remoteIp: args.remoteIp,
        remotePort: args.remotePort,
        sessionId: args.sessionId,
        sessionKey: args.sessionKey,
        plainChunk: toSend,
        chunkIndex: chunkIndex++,
      );
      transferred += toSend.length;
    }

    args.progressPort.send(TransferProgress(
      sessionId: args.sessionId,
      filePath: filePath,
      bytesTransferred: transferred,
      totalBytes: totalBytes,
      completed: true,
    ));
  }
}
