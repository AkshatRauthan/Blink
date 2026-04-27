#!/bin/bash
# Downloads BLAKE3 C reference implementation from upstream.
# Run this once before building the native library.
#
# Source: https://github.com/BLAKE3-team/BLAKE3
# License: CC0 1.0 / Apache 2.0

set -euo pipefail

BLAKE3_VERSION="1.5.4"
BLAKE3_URL="https://github.com/BLAKE3-team/BLAKE3/archive/refs/tags/${BLAKE3_VERSION}.tar.gz"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=$(mktemp -d)

echo "Downloading BLAKE3 v${BLAKE3_VERSION}..."
curl -sL "$BLAKE3_URL" -o "$TEMP_DIR/blake3.tar.gz"

echo "Extracting C sources..."
tar -xzf "$TEMP_DIR/blake3.tar.gz" -C "$TEMP_DIR"

SRC_DIR="$TEMP_DIR/BLAKE3-${BLAKE3_VERSION}/c"

# Core files (required)
cp "$SRC_DIR/blake3.c" "$SCRIPT_DIR/"
cp "$SRC_DIR/blake3_dispatch.c" "$SCRIPT_DIR/"
cp "$SRC_DIR/blake3_portable.c" "$SCRIPT_DIR/"
cp "$SRC_DIR/blake3.h" "$SCRIPT_DIR/blake3_upstream.h"
cp "$SRC_DIR/blake3_impl.h" "$SCRIPT_DIR/"

# x86_64 SIMD intrinsics (optional — for desktop Linux/Windows)
if [ -f "$SRC_DIR/blake3_sse2.c" ]; then
  cp "$SRC_DIR/blake3_sse2.c" "$SCRIPT_DIR/"
  cp "$SRC_DIR/blake3_sse41.c" "$SCRIPT_DIR/"
  cp "$SRC_DIR/blake3_avx2.c" "$SCRIPT_DIR/"
  cp "$SRC_DIR/blake3_avx512.c" "$SCRIPT_DIR/"
fi

# ARM NEON (for Android ARM64)
if [ -f "$SRC_DIR/blake3_neon.c" ]; then
  cp "$SRC_DIR/blake3_neon.c" "$SCRIPT_DIR/"
fi

rm -rf "$TEMP_DIR"

echo "BLAKE3 v${BLAKE3_VERSION} C sources installed to: $SCRIPT_DIR"
echo "Files:"
ls "$SCRIPT_DIR"/*.c 2>/dev/null | while read f; do echo "  $(basename "$f")"; done
