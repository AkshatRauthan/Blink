// ignore_for_file: unused_element
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:ffi/ffi.dart';

import '../../core/utils/logger.dart';

// ── FFI type definitions ──────────────────────────────────────────────────────

final class Blake3ChunkState extends Struct {
  @Array(8)
  external Array<Uint32> cv;

  @Uint64()
  external int chunkCounter;

  @Array(64)
  external Array<Uint8> buf;

  @Uint8()
  external int bufLen;

  @Uint8()
  external int blocksCompressed;

  @Uint8()
  external int flags;
}

final class Blake3Hasher extends Struct {
  external Blake3ChunkState chunk;

  @Array(32)
  external Array<Uint8> key;

  @Array(432)
  external Array<Uint32> cvStack;

  @Uint8()
  external int cvStackLen;
}

typedef _Blake3HasherInitNative = Void Function(Pointer<Blake3Hasher>);
typedef _Blake3HasherInit = void Function(Pointer<Blake3Hasher>);

typedef _Blake3HasherUpdateNative = Void Function(
    Pointer<Blake3Hasher>, Pointer<Uint8>, Size);
typedef _Blake3HasherUpdate = void Function(
    Pointer<Blake3Hasher>, Pointer<Uint8>, int);

typedef _Blake3HasherFinalizeNative = Void Function(
    Pointer<Blake3Hasher>, Pointer<Uint8>, Size);
typedef _Blake3HasherFinalize = void Function(
    Pointer<Blake3Hasher>, Pointer<Uint8>, int);

/// Dart wrapper around the BLAKE3 C library loaded via dart:ffi.
///
/// The native library is compiled from [native/blake3/] via CMake and
/// bundled with the app per-platform.
///
/// BLAKE3 benchmark: ~8–12 GB/s multi-core vs ~0.3 GB/s pure Dart SHA-256.
class NativeHashService {
  NativeHashService._();
  static final instance = NativeHashService._();

  static const int _outputLengthBytes = 32; // 256-bit output

  DynamicLibrary? _lib;
  _Blake3HasherInit? _blake3HasherInit;
  _Blake3HasherUpdate? _blake3HasherUpdate;
  _Blake3HasherFinalize? _blake3HasherFinalize;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      _lib = _loadLibrary();
      _blake3HasherInit = _lib!.lookupFunction<
        _Blake3HasherInitNative,
        _Blake3HasherInit>('blake3_hasher_init');
      _blake3HasherUpdate = _lib!.lookupFunction<
        _Blake3HasherUpdateNative,
        _Blake3HasherUpdate>('blake3_hasher_update');
      _blake3HasherFinalize = _lib!.lookupFunction<
        _Blake3HasherFinalizeNative,
        _Blake3HasherFinalize>('blake3_hasher_finalize');
      _ready = true;
      Log.i(
        'BLAKE3 native library loaded',
        source: LogSource.service,
        component: 'NativeHashService',
      );
    } catch (e) {
      Log.w(
        'BLAKE3 library not available - falling back to Dart SHA-256',
        source: LogSource.service,
        component: 'NativeHashService',
        error: e,
      );
    }
  }

  DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libblink_blake3.so');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libblink_blake3.so');
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('blink_blake3.dll');
    }
    throw UnsupportedError('BLAKE3 FFI not supported on ${Platform.operatingSystem}');
  }

  /// Computes the BLAKE3 hash of [data] and returns a 32-byte digest.
  /// Falls back to a Dart-side implementation if the native library is unavailable.
  Uint8List hash(Uint8List data) {
    if (!_ready ||
        _lib == null ||
        _blake3HasherInit == null ||
        _blake3HasherUpdate == null ||
        _blake3HasherFinalize == null) {
      return _dartFallbackHash(data);
    }

    final hasherPtr = calloc<Blake3Hasher>();
    final outPtr = calloc<Uint8>(_outputLengthBytes);
    try {
      _blake3HasherInit!(hasherPtr);
      if (data.isNotEmpty) {
        final inputPtr = calloc<Uint8>(data.length);
        try {
          inputPtr.asTypedList(data.length).setAll(0, data);
          _blake3HasherUpdate!(hasherPtr, inputPtr, data.length);
        } finally {
          calloc.free(inputPtr);
        }
      }
      _blake3HasherFinalize!(hasherPtr, outPtr, _outputLengthBytes);
      return Uint8List.fromList(outPtr.asTypedList(_outputLengthBytes));
    } catch (e, s) {
      Log.w(
        'Native BLAKE3 hash failed, using fallback',
        source: LogSource.service,
        component: 'NativeHashService',
        error: e,
        stackTrace: s,
      );
      return _dartFallbackHash(data);
    } finally {
      calloc.free(outPtr);
      calloc.free(hasherPtr);
    }
  }

  /// Computes a hash for a byte stream.
  ///
  /// Uses native BLAKE3 when available; otherwise falls back to streamed SHA-256.
  Future<Uint8List> hashByteStream(Stream<List<int>> stream) async {
    if (!_ready ||
        _lib == null ||
        _blake3HasherInit == null ||
        _blake3HasherUpdate == null ||
        _blake3HasherFinalize == null) {
      return _dartFallbackHashStream(stream);
    }

    final hasherPtr = calloc<Blake3Hasher>();
    final outPtr = calloc<Uint8>(_outputLengthBytes);
    final buffered = BytesBuilder(copy: false);
    try {
      _blake3HasherInit!(hasherPtr);
      await for (final chunk in stream) {
        if (chunk.isEmpty) continue;
        buffered.add(chunk);
        final inputPtr = calloc<Uint8>(chunk.length);
        try {
          inputPtr.asTypedList(chunk.length).setAll(0, chunk);
          _blake3HasherUpdate!(hasherPtr, inputPtr, chunk.length);
        } finally {
          calloc.free(inputPtr);
        }
      }
      _blake3HasherFinalize!(hasherPtr, outPtr, _outputLengthBytes);
      return Uint8List.fromList(outPtr.asTypedList(_outputLengthBytes));
    } catch (e, s) {
      Log.w(
        'Native BLAKE3 stream hash failed, using fallback',
        source: LogSource.service,
        component: 'NativeHashService',
        error: e,
        stackTrace: s,
      );
      return _dartFallbackHash(buffered.toBytes());
    } finally {
      calloc.free(outPtr);
      calloc.free(hasherPtr);
    }
  }

  Future<Uint8List> hashFile(File file) async {
    return hashByteStream(file.openRead());
  }

  Future<String> hashFileHex(File file) async {
    final digest = await hashFile(file);
    return _toHex(digest);
  }

  String digestHex(Uint8List digest) => _toHex(digest);

  String _toHex(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  /// Fallback: SHA-256 from Dart (no native acceleration).
  Uint8List _dartFallbackHash(Uint8List data) {
    final digest = crypto.sha256.convert(data);
    return Uint8List.fromList(digest.bytes);
  }

  Future<Uint8List> _dartFallbackHashStream(Stream<List<int>> stream) async {
    final digest = await crypto.sha256.bind(stream).first;
    return Uint8List.fromList(digest.bytes);
  }
}
