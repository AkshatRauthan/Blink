import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../../core/utils/logger.dart';

typedef _Lz4CompressBoundNative = Int32 Function(Int32 inputSize);
typedef _Lz4CompressBound = int Function(int inputSize);

typedef _Lz4CompressNative = Int32 Function(
    Pointer<Uint8> src, Pointer<Uint8> dst, Int32 srcSize, Int32 dstCapacity);
typedef _Lz4Compress = int Function(
    Pointer<Uint8> src, Pointer<Uint8> dst, int srcSize, int dstCapacity);

typedef _Lz4DecompressNative = Int32 Function(
    Pointer<Uint8> src, Pointer<Uint8> dst, Int32 compressedSize, Int32 dstCapacity);
typedef _Lz4Decompress = int Function(
    Pointer<Uint8> src, Pointer<Uint8> dst, int compressedSize, int dstCapacity);

class NativeCompressService {
  NativeCompressService._();
  static final instance = NativeCompressService._();

  DynamicLibrary? _lib;
  _Lz4CompressBound? _lz4CompressBound;
  _Lz4Compress? _lz4Compress;
  _Lz4Decompress? _lz4Decompress;
  bool _ready = false;

  bool get isAvailable => _ready;

  static const _mediaExtensions = {
    '.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.heif',
    '.mp4', '.mkv', '.avi', '.mov', '.webm',
    '.mp3', '.aac', '.ogg', '.flac', '.opus',
    '.zip', '.gz', '.bz2', '.xz', '.7z', '.rar', '.zst',
  };

  static bool shouldCompress(String filePath) {
    final ext = filePath.toLowerCase().split('.').last;
    return !_mediaExtensions.contains('.$ext');
  }

  Future<void> init() async {
    if (_ready) return;
    try {
      _lib = _loadLibrary();
      _lz4CompressBound = _lib!.lookupFunction<
          _Lz4CompressBoundNative, _Lz4CompressBound>('LZ4_compressBound');
      _lz4Compress = _lib!.lookupFunction<
          _Lz4CompressNative, _Lz4Compress>('LZ4_compress_default');
      _lz4Decompress = _lib!.lookupFunction<
          _Lz4DecompressNative, _Lz4Decompress>('LZ4_decompress_safe');
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

  Uint8List? compress(Uint8List data) {
    if (!_ready || _lz4Compress == null || _lz4CompressBound == null) return null;
    if (data.isEmpty) return null;

    final maxDstSize = _lz4CompressBound!(data.length);
    if (maxDstSize <= 0) return null;

    final srcPtr = calloc<Uint8>(data.length);
    final dstPtr = calloc<Uint8>(maxDstSize);
    try {
      srcPtr.asTypedList(data.length).setAll(0, data);
      final compressedSize = _lz4Compress!(srcPtr, dstPtr, data.length, maxDstSize);

      if (compressedSize <= 0) return null;
      if (compressedSize >= data.length) return null;

      return Uint8List.fromList(dstPtr.asTypedList(compressedSize));
    } catch (e, s) {
      Log.w(
        'LZ4 compress failed',
        source: LogSource.service,
        component: 'NativeCompressService',
        error: e,
        stackTrace: s,
      );
      return null;
    } finally {
      calloc.free(srcPtr);
      calloc.free(dstPtr);
    }
  }

  Uint8List? decompress(Uint8List data, int originalSize) {
    if (!_ready || _lz4Decompress == null) return null;
    if (data.isEmpty || originalSize <= 0) return null;

    final srcPtr = calloc<Uint8>(data.length);
    final dstPtr = calloc<Uint8>(originalSize);
    try {
      srcPtr.asTypedList(data.length).setAll(0, data);
      final decompressedSize = _lz4Decompress!(srcPtr, dstPtr, data.length, originalSize);

      if (decompressedSize <= 0) return null;

      return Uint8List.fromList(dstPtr.asTypedList(decompressedSize));
    } catch (e, s) {
      Log.w(
        'LZ4 decompress failed',
        source: LogSource.service,
        component: 'NativeCompressService',
        error: e,
        stackTrace: s,
      );
      return null;
    } finally {
      calloc.free(srcPtr);
      calloc.free(dstPtr);
    }
  }
}
