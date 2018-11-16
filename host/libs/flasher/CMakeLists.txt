cmake_minimum_required(VERSION 3.0)

project(flasher VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

#Hack: for bootloader library
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../../../shared/bootloader shared/bootloader )

add_library(${PROJECT_NAME}
    src/Flasher.cpp
)

target_link_libraries(${PROJECT_NAME} PUBLIC connector bootloader)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)
