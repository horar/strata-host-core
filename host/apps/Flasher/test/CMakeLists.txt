cmake_minimum_required (VERSION 3.1)

project(flasher-test)

set(CMAKE_CXX_STANDARD 11)

set(HOST_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../..")

# include_directories(
#  ${CMAKE_CURRENT_SOURCE_DIR}/../include
# )

set(SOURCES ${SOURCES}
  ${CMAKE_CURRENT_SOURCE_DIR}

)

add_executable(${PROJECT_NAME}
      src/main.cpp
      ${HOST_PATH}/../shared/bootloader/src/util.cpp  #TODO: this should be Library
)

target_link_libraries(${PROJECT_NAME} flasher)
