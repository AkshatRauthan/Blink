cmake_minimum_required(VERSION 3.18)
project(blink_lz4 VERSION 1.0.0 LANGUAGES C)

# LZ4 fast compression library
# Source: https://github.com/lz4/lz4/tree/dev/lib
# TODO: Copy lz4.c and lz4.h from upstream (single-file distribution)

add_library(blink_lz4 SHARED
    lz4.c
)

target_compile_options(blink_lz4 PRIVATE -O3)

set_target_properties(blink_lz4 PROPERTIES
    OUTPUT_NAME "blink_lz4"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
