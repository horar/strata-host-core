cmake_minimum_required (VERSION 3.5.1)
project (HostControllerService)

# The version number
set (HostControllerService_VERSION_MAJOR 1)
set (HostControllerService_VERSION_MINOR 0)

if(WINDOWS)
SET(CMAKE_TOOLCHAIN_FILE x86_64.cmake)
SET(CMAKE_CXX_FLAGS "-v -std=gnu++11 -static-libstdc++ -static-libgcc -static")
endif()

if(LINUX)
SET(CMAKE_CXX_FLAGS "-v -std=c++11")
endif()


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "Debug/")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")

include_directories(lib)
include_directories(lib/ArduinoJson)

if(LINUX) 
include_directories(${CMAKE_CURRENT_SOURCE_DIR}../../lib/linux/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}../../lib/linux/include/event2)
endif()

set(SOURCE
   ${SOURCE}
   ${CMAKE_CURRENT_SOURCE_DIR}/src/ConnectFactory.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/USBConnector.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/ZeroMQConnector.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/HostControllerService.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/startHostControllerService.cpp
)

add_library(usbconnector STATIC ${CMAKE_CURRENT_SOURCE_DIR}/src/USBConnector.cpp)

add_executable(HCS ${SOURCE})

if(WINDOWS)
target_link_libraries(HCS
                      -lzmq.dll
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport.dll
		      -lws2_32
                     )
endif()

if(LINUX)
target_link_libraries(HCS
                      -lzmq
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport
                     )
endif()
