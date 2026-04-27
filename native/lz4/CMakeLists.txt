cmake_minimum_required(VERSION 3.18)
project(blink_lz4 VERSION 1.0.0 LANGUAGES C)

# LZ4 fast compression library
# Source: https://github.com/lz4/lz4/tree/dev/lib
# Run ./setup_sources.sh to download sources before building.

set(LZ4_SOURCES
    lz4.c
)

# Include high-compression variant if available
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/lz4hc.c")
    list(APPEND LZ4_SOURCES lz4hc.c)
endif()

add_library(blink_lz4 SHARED ${LZ4_SOURCES})

target_include_directories(blink_lz4 PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_options(blink_lz4 PRIVATE -O3 -DNDEBUG)

set_target_properties(blink_lz4 PROPERTIES
    OUTPUT_NAME "blink_lz4"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    POSITION_INDEPENDENT_CODE ON
)
