cmake_minimum_required(VERSION 3.0)

project(flasher VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/../shared/bootloader/include
)

add_library(${PROJECT_NAME}
    src/Flasher.cpp
)

target_link_libraries(${PROJECT_NAME} PUBLIC connector)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../../shared/bootloader/include
)
