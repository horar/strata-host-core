cmake_minimum_required(VERSION 3.1)
project(hcs2)     #old: HostControllerService

# The version number
set(HostControllerService_VERSION_MAJOR 1)
set(HostControllerService_VERSION_MINOR 0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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
    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE RelWithDebInfo)
        # set(CMAKE_BUILD_TYPE Debug) # To enable debugging
    endif()

elseif (APPLE)
    message("TOOL CHAIN: mac")

    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE RelWithDebInfo)
        # set(CMAKE_BUILD_TYPE Debug) # To enable debugging
    endif()

    find_library(IOKIT_LIBRARY IOKit)
    find_library(FOUNDATION_LIBRARY Foundation)
else()
    message("ERROR: unsupported operating system !")
endif ()

# set(HOST_CONTROLLER_SERVICE_BINARY_NAME "hcs")
# set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
# set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")

set(NIMBUS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../cloud")
set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../shared")
set(CB_DIR "${NIMBUS_DIR}/couchbase-lite-core")
set(CB_LIB_DIR "${CB_DIR}/build_cmake/unix")

# Compiler definitions for file locations #
# Schema json file
add_definitions(-DNIMBUS_SCHEMA_PATH="${NIMBUS_DIR}/nimbus_command_schema.json")

# TODO:
# Add headers and Library for Nimbus
include_directories(
      .
		include
    include/ArduinoJson

		"${NIMBUS_DIR}"
		"${SHARED_DIR}/cpp-base64"    		#cpp-base64 submodule
    "${SHARED_DIR}/rapidjson/include"   	#rapidjson submodule
		"${CB_DIR}/C"
		"${CB_DIR}/C/include"
		"${CB_DIR}/vendor/fleece/Fleece"
		"${CB_DIR}/LiteCore/Database"
		"${CB_DIR}/build_cmake/unix"
		"${CB_LIB_DIR}"
)

if (APPLE)
    #--- Mac OSX
    message("INCLUDE/LITECORE: mac")

    # Target Files
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../lib/macos/litecore)

    # LiteCore for mac
    find_library(litecore STATIC NAMES LiteCore
            HINTS "${CMAKE_CURRENT_SOURCE_DIR}/../../lib/macos/litecore")
    if (litecore)
        message("Found litecore library")
    else ()
        # Make this Red so its hard to miss
        message("${red} !! Litecore library is missing. Run configure script in cloud/submodule_patches/ !! ${reset_color}")
    endif ()

elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    #--- Linux
    message("INCLUDE/LITECORE: linux")

    # Target Files
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../lib/linux/litecore)

    # LiteCore for mac
    find_library(litecore STATIC NAMES LiteCore
            HINTS "${CMAKE_CURRENT_SOURCE_DIR}/../../../cloud/couchbase-lite-core/build_cmake/unix")
    if (litecore)
        message("Found litecore library")
    else ()
        # Make this Red so its hard to miss
        message("${red} !! Litecore library is missing. Run configure script in cloud/submodule_patches/ !! ${reset_color}")
    endif ()
elseif (CROSSCOMPILE)

    # --- WINDOWS
    message("INCLUDE/LITECORE: windows")

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

else()
    message(FATAL_ERROR "Unknown operating system!")
endif()

add_library(nimbusLib STATIC 	${NIMBUS_DIR}/nimbus_internal.cc
				${NIMBUS_DIR}/couchbase_helper.cpp )

if (APPLE)
  target_link_libraries(nimbusLib PUBLIC -lFleeceStatic ${litecore} )
elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
  target_link_libraries(nimbusLib PUBLIC ${litecore} )
endif()

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

add_executable(${PROJECT_NAME}
    src/HostControllerService.cpp
    src/DiscoveryService.cpp
    src/ParseConfig.cpp
    src/main.cpp
)

target_include_directories(${PROJECT_NAME}
        PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include
        PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}   # for logger
        PRIVATE ${LIBEVENT2_INCLUDE_DIR}
        )

target_link_libraries(${PROJECT_NAME}
    PRIVATE connector nimbusLib libBase64
    PRIVATE ${LIBEVENT2_LIBRARIES}
)

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()

endif()  #CROSSCOMPILE
