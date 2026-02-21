/*
 * LZ4 Dart FFI header — Blink
 *
 * Declares the subset of LZ4 API used by native_compress_service.dart.
 *
 * The actual lz4.c implementation should be obtained from:
 *   https://github.com/lz4/lz4/blob/dev/lib/lz4.c
 *
 * Why LZ4 over zlib/zstd?
 *   - LZ4 compresses at ~700 MB/s (C) — faster than Wi-Fi max throughput
 *   - Decompression at ~4 GB/s — effectively free on the receiver
 *   - zstd gives better ratios but at 5-10x lower speed
 *   - For already-compressed files (JPEG, MP4, ZIP) we skip compression entirely
 */

#ifndef BLINK_LZ4_H
#define BLINK_LZ4_H

#include <stddef.h>

/*
 * Compresses [srcSize] bytes from [src] into [dst].
 * [dstCapacity] must be >= LZ4_compressBound(srcSize).
 * Returns the number of bytes written into dst, or 0 on error.
 */
int LZ4_compress_default(const char *src,
                          char       *dst,
                          int         srcSize,
                          int         dstCapacity);

/*
 * Returns the maximum compressed size for a given [inputSize].
 * Use this to allocate the destination buffer before calling
 * LZ4_compress_default.
 */
int LZ4_compressBound(int inputSize);

/*
 * Decompresses [compressedSize] bytes from [src] into [dst].
 * [dstCapacity] must equal the original uncompressed size.
 * Returns the number of bytes decoded, or a negative value on error.
 */
int LZ4_decompress_safe(const char *src,
                         char       *dst,
                         int         compressedSize,
                         int         dstCapacity);

#endif /* BLINK_LZ4_H */
