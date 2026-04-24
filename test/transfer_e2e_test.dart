import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blink/core/constants/app_constants.dart';
import 'package:blink/services/native/native_crypto_service.dart';
import 'package:blink/services/native/native_hash_service.dart';
import 'package:blink/services/security/crypto_service.dart';
import 'package:blink/services/transfer/http_server_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end transfer test: encrypts chunks, sends over HTTP, server
/// decrypts and writes to disk. Verifies received file matches original.
///
/// Runs entirely on localhost — no network required.
void main() {
  late Uint8List sessionKey;
  late Directory tempDir;

  setUpAll(() async {
    await NativeCryptoService.instance.init();
    await NativeHashService.instance.init();
    sessionKey = NativeCryptoService.instance.generateKey();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('blink_test_');
    HttpServerService.instance.outputBaseDir = tempDir.path;
  });

  tearDown(() async {
    await HttpServerService.instance.stop();
    HttpServerService.instance.outputBaseDir = null;
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('crypto round-trip: encrypt then decrypt produces identical plaintext',
      () {
    final plaintext = Uint8List.fromList(
        List.generate(1024, (i) => i % 256));
    final encrypted = CryptoService.instance.encryptChunk(plaintext, sessionKey);
    final decrypted = CryptoService.instance.decryptChunk(encrypted, sessionKey);

    expect(decrypted, equals(plaintext));
    expect(encrypted.length, greaterThan(plaintext.length));
    // 24 bytes nonce + 16 bytes Poly1305 tag
    expect(encrypted.length, equals(plaintext.length + 24 + 16));
  });

  test('crypto: different nonces per encryption', () {
    final plaintext = Uint8List.fromList([1, 2, 3, 4]);
    final enc1 = CryptoService.instance.encryptChunk(plaintext, sessionKey);
    final enc2 = CryptoService.instance.encryptChunk(plaintext, sessionKey);

    // Nonces (first 24 bytes) must differ
    expect(enc1.sublist(0, 24), isNot(equals(enc2.sublist(0, 24))));
    // Both decrypt to same plaintext
    expect(CryptoService.instance.decryptChunk(enc1, sessionKey),
        equals(plaintext));
    expect(CryptoService.instance.decryptChunk(enc2, sessionKey),
        equals(plaintext));
  });

  test('HTTP server starts and stops cleanly', () async {
    await HttpServerService.instance.start();
    expect(HttpServerService.instance.isRunning, isTrue);

    await HttpServerService.instance.stop();
    expect(HttpServerService.instance.isRunning, isFalse);
  });

  test('end-to-end: send file over HTTP, verify received bytes match',
      () async {
    // 1. Create a test file with known content
    final testFile = File('${tempDir.path}/test_send.bin');
    final testData = Uint8List.fromList(
        List.generate(10000, (i) => i % 256));
    testFile.writeAsBytesSync(testData);

    // 2. Compute checksum for integrity verification
    final checksum = NativeHashService.instance.digestHex(
        NativeHashService.instance.hash(testData));

    // 3. Start server
    await HttpServerService.instance.start();

    // 4. Send session begin with file manifest (includes checksum)
    final httpClient = HttpClient();
    final sessionId = 'test-session-001';

    final beginReq = await httpClient.post(
        '127.0.0.1', AppConstants.transferPort, '/transfer/begin');
    beginReq.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    beginReq.write(jsonEncode({
      'sessionId': sessionId,
      'senderDeviceId': 'test-device',
      'sessionKey': base64Encode(sessionKey),
      'files': [
        {
          'fileId': 'file-001',
          'fileName': 'test_send.bin',
          'mimeType': 'application/octet-stream',
          'sizeBytes': testData.length,
          'blake3Checksum': checksum,
        }
      ],
    }));

    final beginResp = await beginReq.close();
    final beginBody =
        await beginResp.transform(utf8.decoder).join();
    expect(beginResp.statusCode, equals(200));
    expect(jsonDecode(beginBody)['status'], equals('ready'));

    // 5. Send file in chunks, encrypting each one
    final chunkSize = 4000; // Small chunks for testing
    int offset = 0;
    int chunkIndex = 0;
    final events = <ChunkEvent>[];
    final sub = HttpServerService.instance.onChunk.listen(events.add);

    while (offset < testData.length) {
      final end = (offset + chunkSize).clamp(0, testData.length);
      final chunk = testData.sublist(offset, end);

      final encrypted = CryptoService.instance.encryptChunk(
          Uint8List.fromList(chunk), sessionKey);

      final chunkReq = await httpClient.put(
          '127.0.0.1',
          AppConstants.transferPort,
          '/transfer/$sessionId/0');
      chunkReq.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
        ..set(HttpHeaders.contentLengthHeader, encrypted.length.toString())
        ..set('X-Chunk-Index', '$chunkIndex');
      chunkReq.add(encrypted);

      final chunkResp = await chunkReq.close();
      await chunkResp.drain();
      expect(chunkResp.statusCode, equals(200));

      offset = end;
      chunkIndex++;
    }

    // 6. Wait for events to propagate
    await Future.delayed(const Duration(milliseconds: 100));
    await sub.cancel();

    // 7. Verify events
    expect(events, isNotEmpty);
    final lastEvent = events.last;
    expect(lastEvent.fileComplete, isTrue);
    expect(lastEvent.receivedBytes, equals(testData.length));

    // 8. Verify the received file on disk matches the original
    expect(lastEvent.sessionComplete, isTrue);
    final receivedFile = File(
        '${tempDir.path}/Blink/Received/${sessionId.substring(0, 8)}/test_send.bin');
    expect(receivedFile.existsSync(), isTrue);
    expect(receivedFile.readAsBytesSync(), equals(testData));

    httpClient.close();
    await HttpServerService.instance.stop();
  });

  test('server rejects chunk for unknown session', () async {
    await HttpServerService.instance.start();

    final httpClient = HttpClient();
    final req = await httpClient.put(
        '127.0.0.1', AppConstants.transferPort, '/transfer/unknown-session/0');
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/octet-stream');
    req.add([1, 2, 3]);

    final resp = await req.close();
    expect(resp.statusCode, equals(404));

    httpClient.close();
    await HttpServerService.instance.stop();
  });

  test('session status endpoint returns progress', () async {
    await HttpServerService.instance.start();

    final httpClient = HttpClient();
    final sessionId = 'status-test-session';

    // Begin session
    final beginReq = await httpClient.post(
        '127.0.0.1', AppConstants.transferPort, '/transfer/begin');
    beginReq.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    beginReq.write(jsonEncode({
      'sessionId': sessionId,
      'sessionKey': base64Encode(sessionKey),
      'files': [
        {'fileName': 'a.txt', 'sizeBytes': 100},
      ],
    }));
    final beginResp = await beginReq.close();
    await beginResp.drain();

    // Check status
    final statusReq = await httpClient.get(
        '127.0.0.1', AppConstants.transferPort, '/transfer/$sessionId/status');
    final statusResp = await statusReq.close();
    final statusBody = await statusResp.transform(utf8.decoder).join();
    expect(statusResp.statusCode, equals(200));

    final statusJson = jsonDecode(statusBody) as Map<String, dynamic>;
    expect(statusJson['sessionId'], equals(sessionId));
    final files = statusJson['files'] as List;
    expect(files.length, equals(1));
    expect(files[0]['fileName'], equals('a.txt'));
    expect(files[0]['receivedBytes'], equals(0));

    httpClient.close();
    await HttpServerService.instance.stop();
  });

  test('integrity check rejects corrupted transfer', () async {
    final testData = Uint8List.fromList(
        List.generate(5000, (i) => i % 256));
    final wrongChecksum = 'deadbeef' * 8; // 64 hex chars, wrong hash

    await HttpServerService.instance.start();

    final httpClient = HttpClient();
    final sessionId = 'integrity-fail-session';

    // Begin with wrong checksum
    final beginReq = await httpClient.post(
        '127.0.0.1', AppConstants.transferPort, '/transfer/begin');
    beginReq.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    beginReq.write(jsonEncode({
      'sessionId': sessionId,
      'senderDeviceId': 'test-device',
      'sessionKey': base64Encode(sessionKey),
      'files': [
        {
          'fileId': 'file-bad',
          'fileName': 'corrupted.bin',
          'mimeType': 'application/octet-stream',
          'sizeBytes': testData.length,
          'blake3Checksum': wrongChecksum,
        }
      ],
    }));

    final beginResp = await beginReq.close();
    await beginResp.drain();
    expect(beginResp.statusCode, equals(200));

    // Send all data in one chunk
    final encrypted = CryptoService.instance.encryptChunk(testData, sessionKey);
    final chunkReq = await httpClient.put(
        '127.0.0.1', AppConstants.transferPort, '/transfer/$sessionId/0');
    chunkReq.headers
      ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
      ..set(HttpHeaders.contentLengthHeader, encrypted.length.toString())
      ..set('X-Chunk-Index', '0');
    chunkReq.add(encrypted);

    final chunkResp = await chunkReq.close();
    await chunkResp.drain();
    // Should return 422 Unprocessable Entity for integrity failure
    expect(chunkResp.statusCode, equals(422));

    httpClient.close();
    await HttpServerService.instance.stop();
  });
}
