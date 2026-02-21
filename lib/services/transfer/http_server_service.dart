import 'dart:async';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../security/crypto_service.dart';

/// Embedded HTTP server (powered by Shelf) that runs on the receiver side.
///
/// Runs in a dedicated Dart Isolate (spawned by [TransferManager]) so all
/// disk I/O and decryption is off the main thread.
///
/// Endpoints:
///   POST /transfer/begin  — initiates a new transfer session
///   PUT  /transfer/:id    — receives an encrypted chunk stream
///   POST /transfer/:id/metadata — file list + checksums
class HttpServerService {
  HttpServerService._();
  static final instance = HttpServerService._();

  dynamic _server; // HttpServer
  bool _running = false;

  final _chunkController = StreamController<ChunkEvent>.broadcast();

  /// Starts the Shelf server on [AppConstants.transferPort].
  Future<void> start(Uint8List sessionKey) async {
    if (_running) return;

    final router = Router()
      ..post('/transfer/begin', (Request req) => _handleBegin(req, sessionKey))
      ..put('/transfer/<id>', (Request req, String id) => _handleChunk(req, id, sessionKey))
      ..post('/transfer/<id>/metadata', (Request req, String id) => _handleMetadata(req, id));

    final handler = Pipeline()
        .addMiddleware(logRequests(logger: (msg, _) => Log.d('[Server] $msg')))
        .addHandler(router.call);

    _server = await shelf_io.serve(
      handler,
      '0.0.0.0',
      AppConstants.transferPort,
    );
    _running = true;
    Log.i('[HttpServer] Listening on port ${AppConstants.transferPort}');
  }

  Future<Response> _handleBegin(Request req, Uint8List sessionKey) async {
    // TODO: Parse session init payload, return 200 OK with receiver's X25519 pubkey
    return Response.ok('{"status":"ready"}',
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _handleChunk(
      Request req, String sessionId, Uint8List sessionKey) async {
    final encryptedBytes = await req.read().expand((b) => b).toList();
    final chunk = Uint8List.fromList(encryptedBytes);
    final plain = CryptoService.instance.decryptChunk(chunk, sessionKey);
    _chunkController.add(ChunkEvent(sessionId: sessionId, data: plain));
    return Response.ok('{"status":"ok"}',
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _handleMetadata(Request req, String sessionId) async {
    // TODO: Parse and store file metadata for progress tracking
    return Response.ok('{"status":"ok"}',
        headers: {'Content-Type': 'application/json'});
  }

  Stream<ChunkEvent> get onChunk => _chunkController.stream;

  Future<void> stop() async {
    await (_server as dynamic)?.close(force: true);
    _running = false;
    Log.i('[HttpServer] Stopped');
  }
}

class ChunkEvent {
  final String sessionId;
  final Uint8List data;
  const ChunkEvent({required this.sessionId, required this.data});
}
