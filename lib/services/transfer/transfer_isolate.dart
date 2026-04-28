import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../../core/constants/app_constants.dart';
import '../native/native_crypto_service.dart';
import '../native/native_hash_service.dart';
import '../../core/utils/file_utils.dart';

/// Arguments passed to the transfer isolate.
class TransferIsolateArgs {
  final String sessionId;
  final List<String> filePaths;
  final List<String> fileIds;
  final Uint8List sessionKey;
  final String remoteIp;
  final int remotePort;
  final SendPort progressPort;

  const TransferIsolateArgs({
    required this.sessionId,
    required this.filePaths,
    required this.fileIds,
    required this.sessionKey,
    required this.remoteIp,
    required this.remotePort,
    required this.progressPort,
  });
}

/// Progress update sent back to the main isolate.
class TransferProgress {
  final String sessionId;
  final int fileIndex;
  final String filePath;
  final int bytesTransferred;
  final int totalBytes;
  final bool fileComplete;
  final bool sessionComplete;
  final String? error;

  const TransferProgress({
    required this.sessionId,
    required this.fileIndex,
    required this.filePath,
    required this.bytesTransferred,
    required this.totalBytes,
    this.fileComplete = false,
    this.sessionComplete = false,
    this.error,
  });
}

/// Entry point for the file-transfer Dart Isolate.
///
/// Self-contained: initializes its own crypto service, creates its own
/// HTTP client. Does not rely on main-isolate singletons.
Future<void> transferIsolateMain(TransferIsolateArgs args) async {
  // Initialize services in this isolate (isolates don't share state)
  await NativeCryptoService.instance.init();
  await NativeHashService.instance.init();
  final crypto = NativeCryptoService.instance;

  final httpClient = HttpClient()..idleTimeout = AppConstants.httpKeepAlive;
  final chunkSize = AppConstants.chunkSizeBytes;

  // Step 1: Send session begin with file manifest
  final beginOk = await _beginSession(
    httpClient: httpClient,
    args: args,
  );

  if (!beginOk) {
    args.progressPort.send(TransferProgress(
      sessionId: args.sessionId,
      fileIndex: 0,
      filePath: args.filePaths.first,
      bytesTransferred: 0,
      totalBytes: 0,
      error: 'Failed to open session with receiver',
    ));
    httpClient.close();
    return;
  }

  // Step 2: Stream each file
  for (var fileIndex = 0; fileIndex < args.filePaths.length; fileIndex++) {
    final filePath = args.filePaths[fileIndex];
    final file = File(filePath);

    if (!file.existsSync()) {
      args.progressPort.send(TransferProgress(
        sessionId: args.sessionId,
        fileIndex: fileIndex,
        filePath: filePath,
        bytesTransferred: 0,
        totalBytes: 0,
        error: 'File not found: $filePath',
      ));
      continue;
    }

    final totalBytes = await file.length();
    int transferred = 0;
    int chunkIndex = 0;

    final stream = file.openRead();
    final buffer = BytesBuilder(copy: false);

    await for (final bytes in stream) {
      buffer.add(bytes);

      while (buffer.length >= chunkSize) {
        final raw = buffer.takeBytes();
        final toSend = Uint8List.sublistView(raw, 0, chunkSize);
        // Put remaining bytes back
        if (raw.length > chunkSize) {
          buffer.add(raw.sublist(chunkSize));
        }

        // Encrypt in this isolate
        final nonce = crypto.generateNonce();
        final ciphertext = crypto.encrypt(
          plaintext: toSend,
          key: args.sessionKey,
          nonce: nonce,
        );
        final wire = Uint8List.fromList([...nonce, ...ciphertext]);

        final ok = await _sendChunk(
          httpClient: httpClient,
          args: args,
          fileIndex: fileIndex,
          chunkIndex: chunkIndex,
          encrypted: wire,
        );

        if (!ok) {
          args.progressPort.send(TransferProgress(
            sessionId: args.sessionId,
            fileIndex: fileIndex,
            filePath: filePath,
            bytesTransferred: transferred,
            totalBytes: totalBytes,
            error: 'Chunk $chunkIndex failed for $filePath',
          ));
          httpClient.close();
          return;
        }

        transferred += toSend.length;
        chunkIndex++;

        args.progressPort.send(TransferProgress(
          sessionId: args.sessionId,
          fileIndex: fileIndex,
          filePath: filePath,
          bytesTransferred: transferred,
          totalBytes: totalBytes,
        ));
      }
    }

    // Send remaining bytes in final partial chunk
    if (buffer.length > 0) {
      final remaining = buffer.takeBytes();
      final nonce = crypto.generateNonce();
      final ciphertext = crypto.encrypt(
        plaintext: remaining,
        key: args.sessionKey,
        nonce: nonce,
      );
      final wire = Uint8List.fromList([...nonce, ...ciphertext]);

      final ok = await _sendChunk(
        httpClient: httpClient,
        args: args,
        fileIndex: fileIndex,
        chunkIndex: chunkIndex,
        encrypted: wire,
      );

      if (!ok) {
        args.progressPort.send(TransferProgress(
          sessionId: args.sessionId,
          fileIndex: fileIndex,
          filePath: filePath,
          bytesTransferred: transferred,
          totalBytes: totalBytes,
          error: 'Final chunk failed for $filePath',
        ));
        httpClient.close();
        return;
      }

      transferred += remaining.length;
    }

    final isLastFile = fileIndex == args.filePaths.length - 1;
    args.progressPort.send(TransferProgress(
      sessionId: args.sessionId,
      fileIndex: fileIndex,
      filePath: filePath,
      bytesTransferred: transferred,
      totalBytes: totalBytes,
      fileComplete: true,
      sessionComplete: isLastFile,
    ));
  }

  httpClient.close();
}

/// Sends the session-begin request with file manifest.
Future<bool> _beginSession({
  required HttpClient httpClient,
  required TransferIsolateArgs args,
}) async {
  try {
    final req = await httpClient.post(
        args.remoteIp, args.remotePort, '/transfer/begin');
    req.headers
      ..set(HttpHeaders.contentTypeHeader, 'application/json')
      ..set(HttpHeaders.connectionHeader, 'keep-alive');

    final files = <Map<String, dynamic>>[];
    for (var i = 0; i < args.filePaths.length; i++) {
      final file = File(args.filePaths[i]);
      String? checksum;
      if (file.existsSync()) {
        checksum = await NativeHashService.instance.hashFileHex(file);
      }
      files.add({
        'fileId': i < args.fileIds.length ? args.fileIds[i] : '$i',
        'fileName': file.uri.pathSegments.last,
        'mimeType': FileUtils.mimeType(file.path),
        'sizeBytes': file.existsSync() ? file.lengthSync() : 0,
        'blake3Checksum': checksum,
      });
    }

    req.write(jsonEncode({
      'sessionId': args.sessionId,
      'senderDeviceId': '',
      'files': files,
    }));

    final resp = await req.close();
    await resp.drain<void>();
    return resp.statusCode == HttpStatus.ok;
  } catch (_) {
    return false;
  }
}

/// Sends a single encrypted chunk.
Future<bool> _sendChunk({
  required HttpClient httpClient,
  required TransferIsolateArgs args,
  required int fileIndex,
  required int chunkIndex,
  required Uint8List encrypted,
}) async {
  try {
    final req = await httpClient.put(
        args.remoteIp,
        args.remotePort,
        '/transfer/${args.sessionId}/$fileIndex');
    req.headers
      ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
      ..set(HttpHeaders.contentLengthHeader, encrypted.length.toString())
      ..set('X-Chunk-Index', '$chunkIndex');

    req.add(encrypted);
    final resp = await req.close();
    await resp.drain<void>();
    return resp.statusCode == HttpStatus.ok;
  } catch (_) {
    return false;
  }
}
