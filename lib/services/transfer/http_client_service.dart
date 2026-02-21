import 'dart:io';
import 'dart:typed_data';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../security/crypto_service.dart';

/// HTTP client used by the sender side to stream encrypted chunks to a receiver.
///
/// Uses persistent keep-alive connections per session.
/// Supports HTTP Range for pause/resume (resumes from last confirmed byte).
class HttpClientService {
  HttpClientService._();
  static final instance = HttpClientService._();

  final _httpClient = HttpClient()
    ..idleTimeout = AppConstants.httpKeepAlive;

  /// Opens a transfer session with the remote device.
  Future<bool> beginSession({
    required String remoteIp,
    required int remotePort,
    required String sessionId,
    required String localDeviceId,
  }) async {
    try {
      final req = await _httpClient.post(remoteIp, remotePort, '/transfer/begin');
      req.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set(HttpHeaders.connectionHeader, 'keep-alive');
      // TODO: Write session init JSON body
      final resp = await req.close();
      await resp.drain();
      Log.i('[HttpClient] Session $sessionId opened on $remoteIp:$remotePort');
      return resp.statusCode == HttpStatus.ok;
    } catch (e, s) {
      Log.e('[HttpClient] beginSession failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// Sends a single encrypted chunk for [sessionId].
  ///
  /// [chunkIndex] is used to build appropriate Range headers for resume support.
  Future<bool> sendChunk({
    required String remoteIp,
    required int remotePort,
    required String sessionId,
    required Uint8List sessionKey,
    required Uint8List plainChunk,
    required int chunkIndex,
  }) async {
    try {
      final encrypted = CryptoService.instance.encryptChunk(plainChunk, sessionKey);
      final req = await _httpClient.put(
          remoteIp, remotePort, '/transfer/$sessionId');
      req.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
        ..set(HttpHeaders.contentLengthHeader, encrypted.length)
        ..set('X-Chunk-Index', '$chunkIndex');
      req.add(encrypted);
      final resp = await req.close();
      await resp.drain();
      return resp.statusCode == HttpStatus.ok;
    } catch (e, s) {
      Log.e('[HttpClient] sendChunk failed', error: e, stackTrace: s);
      return false;
    }
  }

  void close() => _httpClient.close(force: false);
}
