cmake_minimum_required(VERSION 3.18)
project(blink_native LANGUAGES C)

# Build native libraries for Android (invoked by Gradle via externalNativeBuild)

set(NATIVE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../native")

# BLAKE3
if(EXISTS "${NATIVE_DIR}/blake3/blake3.c")
    add_subdirectory("${NATIVE_DIR}/blake3" "${CMAKE_BINARY_DIR}/blake3")
endif()

# LZ4
if(EXISTS "${NATIVE_DIR}/lz4/lz4.c")
    add_subdirectory("${NATIVE_DIR}/lz4" "${CMAKE_BINARY_DIR}/lz4")
endif()
