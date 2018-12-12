cmake_minimum_required(VERSION 3.5.1)
project(hcs2)     #old: HostControllerService

# The version number
set(HostControllerService_VERSION_MAJOR 1)
set(HostControllerService_VERSION_MINOR 0)

set(CMAKE_CXX_STANDARD 11)

# Add Red color for errors
string(ASCII 27 Esc)
set(red "${Esc}[31m")
set(reset_color "${Esc}[m")

if (CROSSCOMPILE)
    message("Building WINDOWS")
elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    message("Building LINUX")
elseif (APPLE)
    message("Building MAC")
else()
    message("ERROR: unsupported operating system !")
endif ()

if (CROSSCOMPILE)
    message("TOOL CHAIN: windows")
    SET(CMAKE_TOOLCHAIN_FILE ./cmake/x86_64.cmake)
    SET(CMAKE_CXX_FLAGS "-v -std=gnu++11 -static-libstdc++ -static-libgcc -static")
elseif(UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    message("TOOL CHAIN: linux")
    SET(CMAKE_CXX_FLAGS "-v -std=c++11")
    set(CMAKE_BUILD_TYPE Debug)
elseif (APPLE)
    message("TOOL CHAIN: mac")
    SET(CMAKE_CXX_FLAGS "-v -std=c++11")
    set(CMAKE_BUILD_TYPE Debug)
    # To enable debugging
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
    find_library(IOKIT_LIBRARY IOKit)
    find_library(FOUNDATION_LIBRARY Foundation)
else()
    message("ERROR: unsupported operating system !")
endif ()

set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../shared")

set(CB_DIR "${CMAKE_SOURCE_DIR}/CouchBaseLite/couchbase-lite-core")

# Compiler definitions for file locations #
# Schema json file
add_definitions(-DNIMBUS_SCHEMA_PATH="${NIMBUS_DIR}/nimbus_command_schema.json")

# TODO:
# Add headers and Library for Nimbus
include_directories(
    .
	include
    include/ArduinoJson
	"${SHARED_DIR}/cpp-base64"    		#cpp-base64 submodule
    "${SHARED_DIR}/rapidjson/include"   	#rapidjson submodule
)

if (CROSSCOMPILE)
    # --- WINDOWS
    message("INCLUDE/LITECORE: windows")

    # ZMQ
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/windows/zeromq)

    # LibEvent
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/cross-lib/bin)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/cross-lib/lib)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/cross-lib/include)

    # Litecore; Only link LiteCore to HCS. The others will cause problems on crosscompile.
    # Currently they are not needed.
    find_library(litecore NAMES LiteCore HINTS "${NIMBUS_DIR}/bin/x64")
    find_library(litecoreREST NAMES LiteCoreREST HINTS "${NIMBUS_DIR}/bin/x64")
    find_library(fleece NAMES FleeceStatic HINTS "${NIMBUS_DIR}/bin/x64")
    message("Using litecore at: ${litecore}")
    message("Using litecoreREST at: ${litecoreREST}")
    message("Using fleece at: ${fleece}")

    # Overwrite definition for schema; Release backports look in the same folder
    remove_definitions(-DNIMBUS_SCHEMA_PATH)
    add_definitions(-DNIMBUS_SCHEMA_PATH="nimbus_command_schema.json")

else() #CROSSCOMPILE

find_package(Libevent2 REQUIRED)

# Base64 library (external)

add_library(libBase64 ${SHARED_DIR}/cpp-base64/base64.cpp)

target_include_directories(libBase64 PUBLIC ${SHARED_DIR}/cpp-base64)

# HostControllerService ----------------------------------------------------------

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}   # for logger
    ${LIBEVENT2_INCLUDE_DIR}
)

add_executable(${PROJECT_NAME}
    src/HostControllerService.cpp
    src/SGCouchbaseLiteWrapper.cpp
    src/DiscoveryService.cpp
    src/ParseConfig.cpp
    src/main.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE connector libBase64 couchbase-lite-cpp
    PRIVATE ${LIBEVENT2_LIBRARIES}
)

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()


endif()  #CROSSCOMPILE
