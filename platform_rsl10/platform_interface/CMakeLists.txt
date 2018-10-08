cmake_minimum_required(VERSION 3.10)
project(platform_interface C)

set(CMAKE_C_STANDARD 99)

set(CMAKE_BUILD_TYPE Debug)
add_executable(platform_interface main.c cJSON.c dispatch.c queue.c memory_pool.c memory_pool.h)