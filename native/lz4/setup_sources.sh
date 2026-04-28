#!/bin/bash
# Downloads LZ4 C library (single-file distribution) from upstream.
# Run this once before building the native library.
#
# Source: https://github.com/lz4/lz4
# License: BSD 2-Clause

set -euo pipefail

LZ4_VERSION="1.10.0"
LZ4_URL="https://github.com/lz4/lz4/archive/refs/tags/v${LZ4_VERSION}.tar.gz"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=$(mktemp -d)

echo "Downloading LZ4 v${LZ4_VERSION}..."
curl -sL "$LZ4_URL" -o "$TEMP_DIR/lz4.tar.gz"

echo "Extracting C sources..."
tar -xzf "$TEMP_DIR/lz4.tar.gz" -C "$TEMP_DIR"

SRC_DIR="$TEMP_DIR/lz4-${LZ4_VERSION}/lib"

cp "$SRC_DIR/lz4.c" "$SCRIPT_DIR/"
cp "$SRC_DIR/lz4.h" "$SCRIPT_DIR/"
cp "$SRC_DIR/lz4hc.c" "$SCRIPT_DIR/"
cp "$SRC_DIR/lz4hc.h" "$SCRIPT_DIR/"

rm -rf "$TEMP_DIR"

echo "LZ4 v${LZ4_VERSION} C sources installed to: $SCRIPT_DIR"
echo "Files:"
ls "$SCRIPT_DIR"/*.c 2>/dev/null | while read f; do echo "  $(basename "$f")"; done
