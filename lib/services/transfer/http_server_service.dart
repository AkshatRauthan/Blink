import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/chat_message.dart';
import '../native/native_hash_service.dart';
import '../native/native_crypto_service.dart';
import '../security/key_store_service.dart';
import '../security/crypto_service.dart';

/// Metadata for a single file within a transfer session.
class IncomingFileInfo {
  final String fileId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? blake3Checksum;
  int receivedBytes;
  IOSink? sink;
  String? localPath;

  IncomingFileInfo({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.blake3Checksum,
    this.receivedBytes = 0,
  });
}

/// Active incoming transfer session state held by the server.
class IncomingSession {
  final String sessionId;
  final String senderDeviceId;
  final String senderIp;
  final Uint8List sessionKey;
  final List<IncomingFileInfo> files;
  final String outputDir;

  IncomingSession({
    required this.sessionId,
    required this.senderDeviceId,
    required this.senderIp,
    required this.sessionKey,
    required this.files,
    required this.outputDir,
  });
}

class IncomingFileMeta {
  final String fileId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;

  const IncomingFileMeta({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });
}

/// Emitted when POST /transfer/begin creates a new incoming session.
class SessionBeginEvent {
  final String sessionId;
  final String senderDeviceId;
  final String senderIp;
  final int fileCount;
  final int totalBytes;
  final List<IncomingFileMeta> files;

  const SessionBeginEvent({
    required this.sessionId,
    required this.senderDeviceId,
    required this.senderIp,
    required this.fileCount,
    required this.totalBytes,
    required this.files,
  });
}

/// Progress event emitted for each received chunk.
class ChunkEvent {
  final String sessionId;
  final int fileIndex;
  final String fileName;
  final int receivedBytes;
  final int totalBytes;
  final bool fileComplete;
  final bool sessionComplete;
  final String? error;

  const ChunkEvent({
    required this.sessionId,
    required this.fileIndex,
    required this.fileName,
    required this.receivedBytes,
    required this.totalBytes,
    this.fileComplete = false,
    this.sessionComplete = false,
    this.error,
  });
}

/// Embedded HTTP server (powered by Shelf) that runs on the receiver side.
///
/// Endpoints:
///   POST /transfer/begin            — initiates session with file manifest
///   PUT  /transfer/:sid/:fileIndex   — receives encrypted chunk for a file
///   GET  /transfer/:sid/status       — returns session progress
///   DELETE /transfer/:sid            — cancels a session
class HttpServerService {
  HttpServerService._();
  static final instance = HttpServerService._();

  HttpServer? _server;
  bool _running = false;

  /// Override for output base directory. When null, uses path_provider.
  String? outputBaseDir;

  final _sessions = <String, IncomingSession>{};
  final _chunkController = StreamController<ChunkEvent>.broadcast();
  final _beginController = StreamController<SessionBeginEvent>.broadcast();
  final _chatController = StreamController<ChatMessage>.broadcast();

  /// Stream of progress events for all active sessions.
  Stream<ChunkEvent> get onChunk => _chunkController.stream;

  /// Stream emitted once per incoming session when POST /transfer/begin arrives.
  Stream<SessionBeginEvent> get onSessionBegin => _beginController.stream;

  /// Stream of incoming chat messages received via POST /transfer/:sid/chat.
  Stream<ChatMessage> get onChatMessage => _chatController.stream;

  bool get isRunning => _running;

  /// Starts the Shelf server on [AppConstants.transferPort].
  ///
  /// [sessionKey] is the pre-shared key derived via X25519 ECDH.
  /// In the future this will be per-session; for now a single key is used.
  Future<void> start() async {
    if (_running) return;

    final router = Router()
      ..post('/pairing/handshake', _handlePairingHandshake)
      ..post('/transfer/begin', _handleBegin)
      ..put('/transfer/<sid>/<fileIndex>',
          (Request req, String sid, String fileIndex) =>
              _handleChunk(req, sid, int.parse(fileIndex)))
      ..get('/transfer/<sid>/status',
          (Request req, String sid) => _handleStatus(req, sid))
      ..post('/transfer/<sid>/chat',
          (Request req, String sid) => _handleChat(req, sid))
      ..delete('/transfer/<sid>',
          (Request req, String sid) => _handleCancel(req, sid));

    final handler = Pipeline()
        .addMiddleware(
          logRequests(
            logger: (msg, _) => Log.t(
              msg,
              source: LogSource.network,
              component: 'HttpServer',
            ),
          ),
        )
        .addHandler(router.call);

    _server = await shelf_io.serve(
      handler,
      '0.0.0.0',
      AppConstants.transferPort,
    );
    _running = true;
    Log.i(
      'Listening on port ${AppConstants.transferPort}',
      source: LogSource.network,
      component: 'HttpServer',
    );
  }

  /// Registers a session key for an expected incoming session.
  void registerSessionKey(String sessionId, Uint8List sessionKey) {
    final existing = _sessions[sessionId];
    if (existing != null) return;
    _sessions[sessionId] = IncomingSession(
      sessionId: sessionId,
      senderDeviceId: '',
      senderIp: '',
      sessionKey: sessionKey,
      files: [],
      outputDir: '',
    );
  }

  String? remoteIpForSession(String sessionId) => _sessions[sessionId]?.senderIp;

  Future<Response> _handlePairingHandshake(Request req) async {
    try {
      final body = await req.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final sessionId = json['sessionId'] as String? ?? '';
      final senderDeviceId = json['senderDeviceId'] as String? ?? '';
      final senderX25519Pub = json['senderX25519Pub'] as String? ?? '';
      if (sessionId.isEmpty || senderX25519Pub.isEmpty) {
        return Response(400,
            body: '{"error":"Missing sessionId or sender key"}',
            headers: {'Content-Type': 'application/json'});
      }

      final connection = req.context['shelf.io.connection_info']
          as HttpConnectionInfo?;
      final senderIp = connection?.remoteAddress.address ?? '';

      final x25519 = NativeCryptoService.instance.generateX25519KeyPairRaw();
      final sessionKey = NativeCryptoService.instance.deriveSharedKey(
        localSecretKey: x25519.secretKey,
        remotePublicKey: base64Decode(senderX25519Pub),
      );

      _sessions[sessionId] = IncomingSession(
        sessionId: sessionId,
        senderDeviceId: senderDeviceId,
        senderIp: senderIp,
        sessionKey: sessionKey,
        files: [],
        outputDir: '',
      );

      return Response.ok(
        jsonEncode({
          'sessionId': sessionId,
          'receiverDeviceId': KeyStoreService.instance.publicKeyBase64,
          'receiverX25519Pub': base64Encode(x25519.publicKey),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: '{"error":"$e"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /transfer/begin
  ///
  /// Body: { "sessionId": "...", "senderDeviceId": "...", "sessionKey": "base64",
  ///         "files": [{ "fileId": "...", "fileName": "...", "mimeType": "...",
  ///                      "sizeBytes": N, "blake3Checksum": "hex" }] }
  Future<Response> _handleBegin(Request req) async {
    try {
      final body = await req.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final sessionId = json['sessionId'] as String;
      final senderDeviceId = json['senderDeviceId'] as String? ?? '';
      final filesList = json['files'] as List<dynamic>;
        final connection = req.context['shelf.io.connection_info']
          as HttpConnectionInfo?;
        final senderIp = connection?.remoteAddress.address ?? '';

      // Resolve or create session key
      Uint8List sessionKey;
      if (_sessions.containsKey(sessionId)) {
        sessionKey = _sessions[sessionId]!.sessionKey;
      } else {
        return Response(409,
            body: '{"error":"No session key registered or provided"}',
            headers: {'Content-Type': 'application/json'});
      }

      final files = filesList.map((f) {
        final fm = f as Map<String, dynamic>;
        return IncomingFileInfo(
          fileId: fm['fileId'] as String? ?? '',
          fileName: fm['fileName'] as String,
          mimeType: fm['mimeType'] as String? ?? '',
          sizeBytes: fm['sizeBytes'] as int,
          blake3Checksum: fm['blake3Checksum'] as String?,
        );
      }).toList();

      final baseDir = await _resolveDownloadBaseDir();
      final outputDir = p.join(baseDir, 'Blink');
      await Directory(outputDir).create(recursive: true);

      // Open file sinks
      for (final file in files) {
        final category = _folderForMime(file.mimeType);
        final fileDir = p.join(outputDir, category);
        await Directory(fileDir).create(recursive: true);
        final filePath = p.join(fileDir, file.fileName);
        file.localPath = filePath;
        file.sink = File(filePath).openWrite();
      }

      _sessions[sessionId] = IncomingSession(
        sessionId: sessionId,
        senderDeviceId: senderDeviceId,
        senderIp: senderIp.isNotEmpty
            ? senderIp
            : _sessions[sessionId]?.senderIp ?? '',
        sessionKey: sessionKey,
        files: files,
        outputDir: outputDir,
      );

      final sessionTotalBytes = files.fold<int>(0, (s, f) => s + f.sizeBytes);
      _beginController.add(SessionBeginEvent(
        sessionId: sessionId,
        senderDeviceId: senderDeviceId,
        senderIp: senderIp.isNotEmpty
            ? senderIp
            : _sessions[sessionId]?.senderIp ?? '',
        fileCount: files.length,
        totalBytes: sessionTotalBytes,
        files: files
            .map((f) => IncomingFileMeta(
                  fileId: f.fileId,
                  fileName: f.fileName,
                  mimeType: f.mimeType,
                  sizeBytes: f.sizeBytes,
                ))
            .toList(),
      ));

      Log.i(
        'Session $sessionId begun: ${files.length} files from $senderDeviceId',
        source: LogSource.network,
        component: 'HttpServer',
      );

      return Response.ok(
        jsonEncode({'status': 'ready', 'sessionId': sessionId}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, s) {
      Log.e(
        'handleBegin failed',
        source: LogSource.network,
        component: 'HttpServer',
        error: e,
        stackTrace: s,
      );
      return Response.internalServerError(
        body: '{"error":"${e.toString()}"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /transfer/:sid/:fileIndex
  ///
  /// Receives an encrypted chunk, decrypts it, writes to the correct file.
  Future<Response> _handleChunk(
      Request req, String sessionId, int fileIndex) async {
    final session = _sessions[sessionId];
    if (session == null) {
      return Response(404,
          body: '{"error":"Unknown session"}',
          headers: {'Content-Type': 'application/json'});
    }

    if (fileIndex < 0 || fileIndex >= session.files.length) {
      return Response(400,
          body: '{"error":"Invalid fileIndex $fileIndex"}',
          headers: {'Content-Type': 'application/json'});
    }

    final fileInfo = session.files[fileIndex];

    try {
      // Read entire encrypted chunk (4MB + 40 bytes overhead = safe to buffer)
      final encryptedBytes = await _collectBytes(req.read());
      final plaintext =
          CryptoService.instance.decryptChunk(encryptedBytes, session.sessionKey);

      // Write to disk
      fileInfo.sink!.add(plaintext);
      fileInfo.receivedBytes += plaintext.length;

      final fileComplete = fileInfo.receivedBytes >= fileInfo.sizeBytes;
      if (fileComplete) {
        await fileInfo.sink!.flush();
        await fileInfo.sink!.close();
        fileInfo.sink = null;

        // Verify integrity if sender provided a checksum
        if (fileInfo.blake3Checksum != null &&
            fileInfo.blake3Checksum!.isNotEmpty &&
            fileInfo.localPath != null) {
          final receivedHash = await NativeHashService.instance
              .hashFileHex(File(fileInfo.localPath!));
          if (receivedHash != fileInfo.blake3Checksum) {
            Log.e(
              'Integrity check FAILED for ${fileInfo.fileName}: '
              'expected ${fileInfo.blake3Checksum}, got $receivedHash',
              source: LogSource.network,
              component: 'HttpServer',
            );
            _chunkController.add(ChunkEvent(
              sessionId: sessionId,
              fileIndex: fileIndex,
              fileName: fileInfo.fileName,
              receivedBytes: fileInfo.receivedBytes,
              totalBytes: fileInfo.sizeBytes,
              error: 'Integrity check failed',
            ));
            return Response(422,
                body: '{"error":"Integrity check failed"}',
                headers: {'Content-Type': 'application/json'});
          }
          Log.i(
            'Integrity verified for ${fileInfo.fileName}',
            source: LogSource.network,
            component: 'HttpServer',
          );
        }

        Log.i(
          'File ${fileInfo.fileName} complete (${fileInfo.receivedBytes} bytes)',
          source: LogSource.network,
          component: 'HttpServer',
        );
      }

      final sessionComplete =
          session.files.every((f) => f.receivedBytes >= f.sizeBytes);

      _chunkController.add(ChunkEvent(
        sessionId: sessionId,
        fileIndex: fileIndex,
        fileName: fileInfo.fileName,
        receivedBytes: fileInfo.receivedBytes,
        totalBytes: fileInfo.sizeBytes,
        fileComplete: fileComplete,
        sessionComplete: sessionComplete,
      ));

      if (sessionComplete) {
        Log.i(
          'Session $sessionId complete — all files received',
          source: LogSource.network,
          component: 'HttpServer',
        );
        _sessions.remove(sessionId);
      }

      return Response.ok(
        jsonEncode({
          'status': fileComplete ? 'file_complete' : 'ok',
          'receivedBytes': fileInfo.receivedBytes,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, s) {
      Log.e(
        'handleChunk failed for ${fileInfo.fileName}',
        source: LogSource.network,
        component: 'HttpServer',
        error: e,
        stackTrace: s,
      );

      _chunkController.add(ChunkEvent(
        sessionId: sessionId,
        fileIndex: fileIndex,
        fileName: fileInfo.fileName,
        receivedBytes: fileInfo.receivedBytes,
        totalBytes: fileInfo.sizeBytes,
        error: e.toString(),
      ));

      return Response.internalServerError(
        body: '{"error":"Chunk processing failed: $e"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /transfer/:sid/status
  Future<Response> _handleStatus(Request req, String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) {
      return Response(404,
          body: '{"error":"Unknown session"}',
          headers: {'Content-Type': 'application/json'});
    }

    final filesStatus = session.files.map((f) => {
          'fileName': f.fileName,
          'receivedBytes': f.receivedBytes,
          'totalBytes': f.sizeBytes,
          'complete': f.receivedBytes >= f.sizeBytes,
        }).toList();

    return Response.ok(
      jsonEncode({'sessionId': sessionId, 'files': filesStatus}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// POST /transfer/:sid/chat
  Future<Response> _handleChat(Request req, String sessionId) async {
    try {
      final body = await req.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = ChatMessage.fromJson(json);
      _chatController.add(message);
      return Response.ok(
        '{"status":"delivered"}',
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: '{"error":"$e"}',
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /transfer/:sid
  Future<Response> _handleCancel(Request req, String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) {
      return Response(404,
          body: '{"error":"Unknown session"}',
          headers: {'Content-Type': 'application/json'});
    }

    for (final f in session.files) {
      await f.sink?.close();
    }
    _sessions.remove(sessionId);

    Log.i(
      'Session $sessionId cancelled',
      source: LogSource.network,
      component: 'HttpServer',
    );

    return Response.ok(
      '{"status":"cancelled"}',
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Collects all bytes from a stream into a single Uint8List.
  Future<Uint8List> _collectBytes(Stream<List<int>> stream) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  /// Cancels a session from the receiver side (closes sinks, deletes files).
  Future<void> cancelSession(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    for (final f in session.files) {
      await f.sink?.close();
    }
    try {
      for (final f in session.files) {
        if (f.localPath == null) continue;
        final file = File(f.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}
    _sessions.remove(sessionId);
  }

  Future<String> _resolveDownloadBaseDir() async {
    if (outputBaseDir != null) return outputBaseDir!;
    if (Platform.isAndroid) {
      final androidDir = Directory('/storage/emulated/0/Download');
      if (await androidDir.exists()) return androidDir.path;
    }
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) return downloadsDir.path;
    final docsDir = await getApplicationDocumentsDirectory();
    return docsDir.path;
  }

  String _folderForMime(String mimeType) {
    if (mimeType.startsWith('image/')) return 'Image';
    if (mimeType.startsWith('video/')) return 'Video';
    if (mimeType.startsWith('audio/')) return 'Music';
    return 'Document';
  }

  Future<void> stop() async {
    // Close all open file sinks
    for (final session in _sessions.values) {
      for (final f in session.files) {
        await f.sink?.close();
      }
    }
    _sessions.clear();

    await _server?.close(force: true);
    _server = null;
    _running = false;
    Log.i(
      'Stopped',
      source: LogSource.network,
      component: 'HttpServer',
    );
  }
}
