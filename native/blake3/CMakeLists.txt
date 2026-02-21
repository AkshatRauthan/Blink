cmake_minimum_required(VERSION 3.18)
project(blink_blake3 VERSION 1.0.0 LANGUAGES C)

# BLAKE3 reference C implementation
# Source: https://github.com/BLAKE3-team/BLAKE3/tree/master/c
# TODO: Copy blake3.c, blake3_dispatch.c, blake3_portable.c from upstream

add_library(blink_blake3 SHARED
    blake3.c
    blake3_dispatch.c
    blake3_portable.c
)

# Enable platform-specific SIMD acceleration
if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
    # SSE4.1, AVX2, AVX-512 dispatch
    # TODO: Add blake3_sse2.c, blake3_sse41.c, blake3_avx2.c, blake3_avx512.c
    target_compile_options(blink_blake3 PRIVATE -msse4.1)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|ARM64")
    # NEON dispatch
    # TODO: Add blake3_neon.c
    target_compile_options(blink_blake3 PRIVATE -mfpu=neon)
endif()

target_compile_options(blink_blake3 PRIVATE -O3 -ffast-math)

# The Dart FFI loader expects the library under the Flutter bundle
set_target_properties(blink_blake3 PROPERTIES
    OUTPUT_NAME "blink_blake3"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
