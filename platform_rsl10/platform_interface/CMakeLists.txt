cmake_minimum_required(VERSION 3.10)
project(platform_interface C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_BUILD_TYPE Debug)
set(COMPONENTS_DIR ../../platform/components)
set(LIBRARIES memory_pool)

# include memory_pool.h file
include_directories(${COMPONENTS_DIR}/memory_pool/include/memory_pool)
# include cJson.h file
include_directories(external_libraries)

link_directories(${COMPONENTS_DIR}/memory_pool/build/memory_pool-1.0.0-Darwin/lib)

add_executable(platform_interface main.c external_libraries/cJSON.c dispatch.c queue.c)

target_link_libraries(platform_interface ${LIBRARIES})
