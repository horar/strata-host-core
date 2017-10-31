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
SET(CMAKE_C_COMPILER "clang")
SET(CMAKE_CXX_COMPILER "clang++")
endif()


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "Debug/")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")

############# cloud integration
# Required headers
set(NIMBUS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../cloud/")
set(CB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../cloud/couchbase-lite-core")
set(CB_LIB_DIR "${CB_DIR}/build_cmake/unix")
set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../shared")
message (${CB_LIB_DIR})
include_directories( ${CMAKE_CURRENT_SOURCE_DIR}
          "${CMAKE_CURRENT_SOURCE_DIR}/include"
          "${SHARED_DIR}/cpp-base64"    #cpp-base64 submodule
          "${SHARED_DIR}/rapidjson/include"   #rapidjson submodule
          "${CB_DIR}/C"
          "${CB_DIR}/C/include"
          "${CB_DIR}/vendor/fleece/Fleece"
          "${CB_DIR}/LiteCore/Database"
          "${CB_DIR}/build_cmake/unix"
          "${CB_LIB_DIR}"
          "${NIMBUS_DIR}"
          )

find_library(litecore NAMES
      LiteCore
      #FleeceStatic
      #BLIPstatic
      HINTS "${CB_LIB_DIR}")
find_library(libdl dl)

include_directories(lib)
include_directories(lib/ArduinoJson)

if(LINUX) 
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/include/event2)
#link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/lib/event2)
#link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/lib)
endif()

set(SOURCE
   ${SOURCE}
   ${CMAKE_CURRENT_SOURCE_DIR}/src/ConnectFactory.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/USBConnector.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/ZeroMQConnector.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/HostControllerService.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/startHostControllerService.cpp
   #${CMAKE_CURRENT_SOURCE_DIR}/src/Observer.cpp
   ${SHARED_DIR}/cpp-base64/base64.cpp
   ${NIMBUS_DIR}/nimbus.cc
)

add_library(usbconnector STATIC ${CMAKE_CURRENT_SOURCE_DIR}/src/USBConnector.cpp)

add_executable(HCS ${SOURCE})

add_executable (HCC_NIMBUS_TEST   ${CMAKE_CURRENT_SOURCE_DIR}/src/HCC_NIMBUS_TEST.cpp
${SHARED_DIR}/cpp-base64/base64.cpp)

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
                      ${litecore} ${libdl}
                     )
endif()

target_link_libraries(HCC_NIMBUS_TEST
                      -lzmq
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport
                      ${litecore} ${libdl}
                     )