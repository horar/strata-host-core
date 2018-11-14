cmake_minimum_required(VERSION 3.5.1)
project(connector)

# The version number
set(HostControllerService_VERSION_MAJOR 1)
set(HostControllerService_VERSION_MINOR 0)

set(CMAKE_CXX_STANDARD 11)

find_package(SerialPort REQUIRED)
find_package(ZeroMQ REQUIRED)

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)
set(SHARED_DIR ${CMAKE_SOURCE_DIR}/../shared)

if (CROSSCOMPILE)
    message("TOOL CHAIN: windows")
    SET(CMAKE_TOOLCHAIN_FILE ./cmake/x86_64.cmake)
    SET(CMAKE_CXX_FLAGS "-v -std=gnu++11 -static-libstdc++ -static-libgcc -static")
endif ()


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
endif ()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include
      ${SERIAL_PORT_INCLUDE_DIR}
      ${ZEROMQ_INCLUDE_DIR}
      ${EXT_LIBS_PATH}/zmq/include      # This is hack
      ${SHARED_DIR}/rapidjson/include
)

add_library(connector
    src/SerialConnector.cpp
    src/PubSubConnector.cpp
    src/RequestReplyConnector.cpp
    src/ZMQConnector.cpp
)

target_link_libraries(connector
      PUBLIC ${SERIAL_PORT_LIBRARIES}
      PUBLIC ${ZEROMQ_LIBRARIES}
)

if (CROSSCOMPILE)
    message("LINKING: windows")
    target_link_libraries(connector
            -lzmq.dll
            -lstdc++
            -lpthread
            -lserialport.dll
            -lws2_32
            )
endif ()

target_include_directories(connector
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC ${SERIAL_PORT_INCLUDE_DIR}
    PUBLIC ${EXT_LIBS_PATH}/zmq/include
    PUBLIC ${SHARED_DIR}/rapidjson/include
)
