cmake_minimum_required(VERSION 3.10)
project(platform_interface C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_BUILD_TYPE Debug)
set(COMPONENTS_DIR ../../platform/components)
set(EXTLIB_DIR ../../platform/ext_libs)

add_subdirectory(${COMPONENTS_DIR}/memory_pool memory_pool)

add_subdirectory(${EXTLIB_DIR}/cJSON cJSON)

add_library(platform_interface
        STATIC src/platform_interface_implementation.c
)
target_include_directories(
        platform_interface
        PUBLIC include
        PUBLIC include/platfrom_interface
)

target_link_libraries(platform_interface memory_pool cJSON)

add_executable(platform_interface_example
        test_example/example.c
        test_example/platform_command_implementation.c
        )

target_link_libraries(platform_interface_example platform_interface)
