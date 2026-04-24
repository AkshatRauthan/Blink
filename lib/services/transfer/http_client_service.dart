import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../security/crypto_service.dart';

/// Metadata describing a file to be transferred.
class OutgoingFileInfo {
  final String fileId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? blake3Checksum;

  const OutgoingFileInfo({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.blake3Checksum,
  });

  Map<String, dynamic> toJson() => {
        'fileId': fileId,
        'fileName': fileName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'blake3Checksum': blake3Checksum,
      };
}

/// HTTP client used by the sender side to stream encrypted chunks to a receiver.
///
/// Protocol:
///   1. POST /transfer/begin  — send session metadata + file manifest
///   2. PUT  /transfer/:sid/:fileIndex  — stream encrypted chunks per file
class HttpClientService {
  HttpClientService._();
  static final instance = HttpClientService._();

  HttpClient? _httpClient;

  HttpClient get _client {
    _httpClient ??= HttpClient()..idleTimeout = AppConstants.httpKeepAlive;
    return _httpClient!;
  }

  /// Opens a transfer session with the remote device.
  ///
  /// Sends the file manifest so the receiver can prepare output files.
  Future<bool> beginSession({
    required String remoteIp,
    required int remotePort,
    required String sessionId,
    required String senderDeviceId,
    required Uint8List sessionKey,
    required List<OutgoingFileInfo> files,
  }) async {
    try {
      final req =
          await _client.post(remoteIp, remotePort, '/transfer/begin');
      req.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set(HttpHeaders.connectionHeader, 'keep-alive');

      final body = jsonEncode({
        'sessionId': sessionId,
        'senderDeviceId': senderDeviceId,
        'sessionKey': base64Encode(sessionKey),
        'files': files.map((f) => f.toJson()).toList(),
      });

      req.write(body);
      final resp = await req.close();
      final respBody = await resp.transform(utf8.decoder).join();

      if (resp.statusCode == HttpStatus.ok) {
        Log.i(
          'Session $sessionId opened on $remoteIp:$remotePort',
          source: LogSource.network,
          component: 'HttpClient',
        );
        return true;
      }

      Log.w(
        'beginSession rejected: $respBody',
        source: LogSource.network,
        component: 'HttpClient',
      );
      return false;
    } catch (e, s) {
      Log.e(
        'beginSession failed',
        source: LogSource.network,
        component: 'HttpClient',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  /// Sends a single encrypted chunk for a specific file in the session.
  ///
  /// Returns the number of bytes the receiver has accumulated for this file,
  /// or -1 on failure.
  Future<int> sendChunk({
    required String remoteIp,
    required int remotePort,
    required String sessionId,
    required Uint8List sessionKey,
    required Uint8List plainChunk,
    required int fileIndex,
    required int chunkIndex,
  }) async {
    try {
      final encrypted =
          CryptoService.instance.encryptChunk(plainChunk, sessionKey);

      final req = await _client.put(
          remoteIp, remotePort, '/transfer/$sessionId/$fileIndex');
      req.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
        ..set(HttpHeaders.contentLengthHeader, encrypted.length.toString())
        ..set('X-Chunk-Index', '$chunkIndex');

      req.add(encrypted);
      final resp = await req.close();
      final respBody = await resp.transform(utf8.decoder).join();

      if (resp.statusCode == HttpStatus.ok) {
        final respJson = jsonDecode(respBody) as Map<String, dynamic>;
        return respJson['receivedBytes'] as int? ?? -1;
      }

      Log.w(
        'sendChunk rejected ($fileIndex/$chunkIndex): $respBody',
        source: LogSource.network,
        component: 'HttpClient',
      );
      return -1;
    } catch (e, s) {
      Log.e(
        'sendChunk failed ($fileIndex/$chunkIndex)',
        source: LogSource.network,
        component: 'HttpClient',
        error: e,
        stackTrace: s,
      );
      return -1;
    }
  }

  void close() {
    _httpClient?.close(force: false);
    _httpClient = null;
  }
}
