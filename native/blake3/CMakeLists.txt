cmake_minimum_required(VERSION 3.18)
project(blink_blake3 VERSION 1.0.0 LANGUAGES C)

# BLAKE3 reference C implementation
# Source: https://github.com/BLAKE3-team/BLAKE3/tree/master/c
# Run ./setup_sources.sh to download sources before building.

set(BLAKE3_SOURCES
    blake3.c
    blake3_dispatch.c
    blake3_portable.c
)

# Platform-specific SIMD acceleration
if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|x86")
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/blake3_sse2.c")
        list(APPEND BLAKE3_SOURCES blake3_sse2.c blake3_sse41.c blake3_avx2.c blake3_avx512.c)
        set(BLAKE3_SIMD_FLAGS "-msse2 -msse4.1 -mavx2")
    endif()
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64|ARM64")
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/blake3_neon.c")
        list(APPEND BLAKE3_SOURCES blake3_neon.c)
        add_compile_definitions(BLAKE3_USE_NEON=1)
    endif()
endif()

add_library(blink_blake3 SHARED ${BLAKE3_SOURCES})

target_include_directories(blink_blake3 PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_definitions(blink_blake3 PRIVATE BLAKE3_VERSION_STRING="1.5.4")
target_compile_options(blink_blake3 PRIVATE -O3 -DNDEBUG)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|x86")
    # Per-file SIMD flags for x86
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/blake3_sse2.c")
        set_source_files_properties(blake3_sse2.c PROPERTIES COMPILE_FLAGS "-msse2")
        set_source_files_properties(blake3_sse41.c PROPERTIES COMPILE_FLAGS "-msse4.1")
        set_source_files_properties(blake3_avx2.c PROPERTIES COMPILE_FLAGS "-mavx2")
        set_source_files_properties(blake3_avx512.c PROPERTIES COMPILE_FLAGS "-mavx512f -mavx512vl")
    endif()
endif()

set_target_properties(blink_blake3 PROPERTIES
    OUTPUT_NAME "blink_blake3"
    POSITION_INDEPENDENT_CODE ON
)

# Only set output dir when built standalone (not as subdirectory)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  set_target_properties(blink_blake3 PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
  )
endif()
