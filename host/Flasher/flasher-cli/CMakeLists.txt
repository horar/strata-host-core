cmake_minimum_required (VERSION 2.8)

project (flasher-app)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

#Set Path
set(HOST_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../..")
set(HCS2_PATH "${HOST_PATH}/hcs2")

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/../include
)

set(SOURCES ${SOURCES}
  ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
  ${HOST_PATH}/../shared/bootloader/src/util.cpp
)

add_executable(${PROJECT_NAME} ${SOURCES})

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(${PROJECT_NAME} flasher)
