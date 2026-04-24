// ignore_for_file: unused_element
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import '../../core/utils/logger.dart';

// ── FFI type definitions ──────────────────────────────────────────────────────

typedef _Lz4CompressNative = Int32 Function(
    Pointer<Uint8> src, Pointer<Uint8> dst, Int32 srcSize, Int32 dstCapacity);
typedef _Lz4Compress = int Function(
    Pointer<Uint8> src, Pointer<Uint8> dst, int srcSize, int dstCapacity);

typedef _Lz4DecompressNative = Int32 Function(
    Pointer<Uint8> src, Pointer<Uint8> dst, Int32 compressedSize, Int32 dstCapacity);
typedef _Lz4Decompress = int Function(
    Pointer<Uint8> src, Pointer<Uint8> dst, int compressedSize, int dstCapacity);

/// Dart wrapper around the LZ4 C library loaded via dart:ffi.
///
/// LZ4 is used for optional pre-encryption compression of non-media files.
/// Native C speed: ~700 MB/s compression vs ~80 MB/s pure Dart equivalents.
///
/// Skip compression for image/video files — they're already compressed.
class NativeCompressService {
  NativeCompressService._();
  static final instance = NativeCompressService._();

  DynamicLibrary? _lib;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      _lib = _loadLibrary();
      _ready = true;
      Log.i(
        'LZ4 native library loaded',
        source: LogSource.service,
        component: 'NativeCompressService',
      );
    } catch (e) {
      Log.w(
        'LZ4 library not available - compression disabled',
        source: LogSource.service,
        component: 'NativeCompressService',
        error: e,
      );
    }
  }

  DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('libblink_lz4.so');
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('blink_lz4.dll');
    }
    throw UnsupportedError('LZ4 FFI not supported on ${Platform.operatingSystem}');
  }

  /// Compresses [data] using LZ4 fast mode.
  /// Returns null if native library unavailable or compression would expand data.
  Uint8List? compress(Uint8List data) {
    if (!_ready || _lib == null) return null;
    // TODO: Call LZ4_compress_default via _lib lookup
    return null;
  }

  /// Decompresses LZ4-compressed [data] into a buffer of [originalSize] bytes.
  Uint8List? decompress(Uint8List data, int originalSize) {
    if (!_ready || _lib == null) return null;
    // TODO: Call LZ4_decompress_safe via _lib lookup
    return null;
  }
}
