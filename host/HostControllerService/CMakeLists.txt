cmake_minimum_required (VERSION 3.5.1)
project (HostControllerService)

# The version number
set (HostControllerService_VERSION_MAJOR 1)
set (HostControllerService_VERSION_MINOR 0)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x -levent")
set(GCC_COMPILE_FLAGS "-std=c++11")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "Debug/")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")

include_directories(lib)
include_directories(lib/ArduinoJson)

set(SOURCE
   ${SOURCE}
   ${CMAKE_CURRENT_SOURCE_DIR}/src/ConnectFactory.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/USBConnector.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/ZeroMQConnector.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/HostControllerService.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/startHostControllerService.cpp
)

add_executable(HCS ${SOURCE})

target_link_libraries(HCS
                      -lzmq
                      -lstdc++
                      -lpthread
                      -levent
                     )

