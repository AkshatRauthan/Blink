/*
 * BLAKE3 Dart FFI header — Blink
 *
 * This file declares the C interface used by native_hash_service.dart
 * via dart:ffi / ffigen.
 *
 * Actual implementation files (blake3.c, blake3_dispatch.c, etc.) should be
 * copied from the official BLAKE3 reference C implementation:
 *   https://github.com/BLAKE3-team/BLAKE3/tree/master/c
 *
 * Performance: ~8–12 GB/s with SIMD on modern CPUs vs ~0.3 GB/s Dart SHA-256.
 */

#ifndef BLINK_BLAKE3_H
#define BLINK_BLAKE3_H

#include <stdint.h>
#include <stddef.h>

#define BLAKE3_OUT_LEN 32      /* 256-bit output */
#define BLAKE3_KEY_LEN 32
#define BLAKE3_BLOCK_LEN 64
#define BLAKE3_CHUNK_LEN 1024

typedef struct {
  uint32_t cv[8];
  uint64_t chunk_counter;
  uint8_t  buf[BLAKE3_BLOCK_LEN];
  uint8_t  buf_len;
  uint8_t  blocks_compressed;
  uint8_t  flags;
} blake3_chunk_state;

typedef struct {
  blake3_chunk_state chunk;
  uint8_t  key[BLAKE3_KEY_LEN];
  uint32_t cv_stack[8 * 54];
  uint8_t  cv_stack_len;
} blake3_hasher;

/* Initialise a hasher for plain hashing (no key). */
void blake3_hasher_init(blake3_hasher *self);

/* Feed input bytes into the hasher. */
void blake3_hasher_update(blake3_hasher *self,
                           const void *input,
                           size_t      input_len);

/*
 * Finalise and write [out_len] bytes to [out].
 * For a standard 256-bit hash, set out_len = BLAKE3_OUT_LEN.
 */
void blake3_hasher_finalize(const blake3_hasher *self,
                             uint8_t            *out,
                             size_t              out_len);

#endif /* BLINK_BLAKE3_H */
