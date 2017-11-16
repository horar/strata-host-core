cmake_minimum_required (VERSION 3.5.1)
project (HostControllerService)

# The version number
set (HostControllerService_VERSION_MAJOR 1)
set (HostControllerService_VERSION_MINOR 0)

# Add Red color for errors
string(ASCII 27 Esc)
set (red "${Esc}[31m")
set (reset_color "${Esc}[m")

if(WINDOWS )
SET(CMAKE_TOOLCHAIN_FILE x86_64.cmake)
SET(CMAKE_CXX_FLAGS "-v -std=gnu++11 -static-libstdc++ -static-libgcc -static")
endif()

if(LINUX OR MAC)
SET(CMAKE_CXX_FLAGS "-v -std=c++11")
endif()


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "Debug/")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")
set(NIMBUS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../cloud")
set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../shared")
set(CB_DIR "${NIMBUS_DIR}/couchbase-lite-core")
set(CB_LIB_DIR "${CB_DIR}/build_cmake/unix")

include_directories(lib)
include_directories(lib/ArduinoJson)

# Add headers and Library for Nimbus
include_directories(${NIMBUS_DIR}
		"${SHARED_DIR}/cpp-base64"    		#cpp-base64 submodule
          	"${SHARED_DIR}/rapidjson/include"   	#rapidjson submodule
		"${CB_DIR}/C"
		"${CB_DIR}/C/include"
		"${CB_DIR}/vendor/fleece/Fleece"
		"${CB_DIR}/LiteCore/Database"
		"${CB_DIR}/build_cmake/unix"
		"${CB_LIB_DIR}"
		)
add_library(nimbusLib STATIC ${NIMBUS_DIR}/nimbus_internal.cc)

if(WINDOWS)
# ZMQ
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/windows/zeromq)
# LibEvent
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/cross-lib/bin)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/cross-lib/lib)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/cross-lib/include)
# Litecore
find_library(litecore STATIC NAMES LiteCore HINTS "${NIMBUS_DIR}/bin/x64")
message("Using litecore at: ${litecore}")
endif()

if(MAC)
# Include Files
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include/macos/libserial)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include/macos/libevent)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include/macos/libevent/event2)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include/macos/libzmq)
# Target Files
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/mac/libevents)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/mac/libserial)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/mac/libzmq)

# LiteCore
find_library(litecore STATIC NAMES LiteCore
				HINTS "${CMAKE_CURRENT_SOURCE_DIR}/../lib/mac/litecore")
if(litecore)
message("Found litecore library")
else()
# Make this Red so its hard to miss
message("${red} !! Litecore library is missing. Run configure script in cloud/submodule_patches/ !! ${reset_color}")
endif()
endif()


if(LINUX)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/include/event2)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/lib/event2)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/lib)

# LiteCore
find_library(litecore STATIC NAMES LiteCore
				HINTS "${CMAKE_CURRENT_SOURCE_DIR}/../../cloud/couchbase-lite-core/build_cmake/unix")
if(litecore)
message("Found litecore library")
else()
# Make this Red so its hard to miss
message("${red} !! Litecore library is missing. Run configure script in cloud/submodule_patches/ !! ${reset_color}")
endif()

endif()

set(SOURCE
   ${SOURCE}
   ${CMAKE_CURRENT_SOURCE_DIR}/src/ConnectFactory.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/USBConnector.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/ZeroMQConnector.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/HostControllerService.cpp
   ${CMAKE_CURRENT_SOURCE_DIR}/src/startHostControllerService.cpp
   ${SHARED_DIR}/cpp-base64/base64.cpp
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
		      nimbusLib
		      ${litecore}
                     )
endif()

if(LINUX)
target_link_libraries(HCS
                      -lzmq
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport
		      nimbusLib
		      ${litecore}
                     )
endif()

if(MAC)
target_link_libraries(HCS
											-lzmq
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport
		      nimbusLib
		      ${litecore}
                     )
endif()
