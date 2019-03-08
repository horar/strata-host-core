project(HostControllerService)

# The version number
set(HostControllerService_VERSION_MAJOR 1)
set(HostControllerService_VERSION_MINOR 0)

# Add Red color for errors
string(ASCII 27 Esc)
set(red "${Esc}[31m")
set(reset_color "${Esc}[m")

if (CROSSCOMPILE)
    message("Building WINDOWS booo...")
elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    message("Building LINUX yea...")
elseif (APPLE)
    message("Building MAC yea...")
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

set(HOST_CONTROLLER_SERVICE_BINARY_NAME "hcs")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")
set(NIMBUS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../cloud")
set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../shared")
set(CB_DIR "${NIMBUS_DIR}/couchbase-lite-core")
set(CB_LIB_DIR "${CB_DIR}/build_cmake/unix")

# Compiler definitions for file locations #
# Schema json file
add_definitions(-DNIMBUS_SCHEMA_PATH="${CMAKE_CURRENT_SOURCE_DIR}/../../cloud/nimbus_command_schema.json")

# Add headers and Library for Nimbus
include_directories(
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
add_library(nimbusLib STATIC 	${NIMBUS_DIR}/nimbus_internal.cc
				${NIMBUS_DIR}/couchbase_helper.cpp )

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


elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    #--- LINUX
    message("INCLUDE/LITECORE: linux")

    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/include)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/include/event2)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/lib/event2)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/linux/lib)

    # LiteCore for linux/unix
    find_library(litecore STATIC NAMES LiteCore
            HINTS "${CMAKE_CURRENT_SOURCE_DIR}/../../cloud/couchbase-lite-core/build_cmake/unix")

    if (litecore)
        message("Found litecore library")
    else ()
        # Make this Red so its hard to miss
        message("${red} !! Litecore library is missing. Run configure script in cloud/submodule_patches/ !! ${reset_color}")
    endif ()

elseif (APPLE)
    #--- Mac OSX
    message("INCLUDE/LITECORE: mac")

    # Include Files
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include/macos/libserial)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include/macos/libevent)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include/macos/libevent/event2)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include/macos/libzmq)
    # Target Files
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/macos/libevents)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/macos/libserial)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/macos/libzmq)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/macos/litecore)
    # LiteCore for mac
    find_library(litecore STATIC NAMES LiteCore
            HINTS "${CMAKE_CURRENT_SOURCE_DIR}/../lib/macos/litecore")
    if (litecore)
        message("Found litecore library")
    else ()
        # Make this Red so its hard to miss
        message("${red} !! Litecore library is missing. Run configure script in cloud/submodule_patches/ !! ${reset_color}")
    endif ()

else()
    message("ERROR: unsupported operating system !")
endif ()

set(SOURCE
        ${SOURCE}
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ConnectFactory.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/USBConnector.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ZeroMQConnector.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/HostControllerService.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
        ${SHARED_DIR}/cpp-base64/base64.cpp
        src/ParseConfig.cpp)

add_library(usbconnector STATIC ${CMAKE_CURRENT_SOURCE_DIR}/src/USBConnector.cpp)

add_executable(${HOST_CONTROLLER_SERVICE_BINARY_NAME} ${SOURCE})

if (CROSSCOMPILE)
    message("LINKING: windows")
    target_link_libraries(${HOST_CONTROLLER_SERVICE_BINARY_NAME}
            -lzmq.dll
            -lstdc++
            -lpthread
            -levent
            -lserialport.dll
            -lws2_32
            nimbusLib
            ${litecore}
            )
elseif( UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    message("LINKING: linux")
    target_link_libraries(${HOST_CONTROLLER_SERVICE_BINARY_NAME}
            -lzmq
            -lstdc++
            -lpthread
            -levent
            -lserialport
            nimbusLib
            ${litecore}
            )
elseif (APPLE)
    message("LINKING: mac")
    target_link_libraries(${HOST_CONTROLLER_SERVICE_BINARY_NAME}
            -lzmq
            -lstdc++
            -lpthread
            -levent
            -lserialport
            -lFleeceStatic
            nimbusLib
            ${litecore}
            ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
            )

else()
    message("ERROR: unsupported operating system !")
endif ()
