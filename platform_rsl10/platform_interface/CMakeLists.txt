cmake_minimum_required(VERSION 3.10)
project(platform_interface C)

set(CMAKE_C_STANDARD 99)

set(CMAKE_BUILD_TYPE Debug)

include_directories(../../platform/components/memory_pool/include/memory_pool)

file(GLOB LIBRARIES "../../platform/components/memory_pool/build/memory_pool-1.0.0-Darwin/lib/*.dylib")

add_executable(platform_interface main.c cJSON.c dispatch.c queue.c)

target_link_libraries(platform_interface ${LIBRARIES})
