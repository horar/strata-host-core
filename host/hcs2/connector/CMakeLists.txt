cmake_minimum_required(VERSION 3.5.1)
project(connectors)

# The version number
set(HostControllerService_VERSION_MAJOR 1)
set(HostControllerService_VERSION_MINOR 0)

set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../shared")

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
else()
    message("ERROR: unsupported operating system !")
endif ()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")

if (CROSSCOMPILE)
    # --- WINDOWS
    message("INCLUDE/LITECORE: windows")
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
    # --- WINDOWS
    message("INCLUDE/LITECORE: windows")

    # LibEvent
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/cross-lib/bin)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/cross-lib/lib)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../lib/cross-lib/include)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)
    include_directories(${SHARED_DIR}/rapidjson/include)
    # ZMQ
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../lib/windows/zeromq)

elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    #--- LINUX
    message("INCLUDE/LITECORE: linux")
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../lib/linux/include)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
    include_directories(${SHARED_DIR}/rapidjson/include)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../lib/linux/lib)

elseif (APPLE)
    #--- Mac OSX
    message("INCLUDE/LITECORE: mac")

    # Include Files
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../include/macos/libserial)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../include/macos/libzmq)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
    include_directories(${SHARED_DIR}/rapidjson/include)
    # Target Files
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/macos/libserial)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../lib/macos/libzmq)

else()
    message("ERROR: unsupported operating system !")
endif ()

set(SOURCE
        ${SOURCE}
        ${CMAKE_CURRENT_SOURCE_DIR}/src/SerialConnector.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ZMQConnector.cc
        )

add_library(libconnectors.so ${SOURCE})

if (CROSSCOMPILE)
    message("LINKING: windows")
    target_link_libraries(libconnectors.so
            -lzmq.dll
            -lstdc++
            -lpthread
            -lserialport.dll
            -lws2_32
            )
elseif( UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    message("LINKING: linux")
    target_link_libraries(libconnectors.so
            -lzmq
            -lstdc++
            -lpthread
            -lserialport
            )
elseif (APPLE)
    message("LINKING: mac")
    target_link_libraries(libconnectors.so
            -lzmq
            -lstdc++
            -lpthread
            -lserialport
            )

else()
    message("ERROR: unsupported operating system !")
endif ()

target_include_directories (libconnectors.so PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
