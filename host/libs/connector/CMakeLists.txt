cmake_minimum_required(VERSION 3.5.1)
project(connector)

# The version number
set(HostControllerService_VERSION_MAJOR 1)
set(HostControllerService_VERSION_MINOR 0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(SerialPort REQUIRED)
find_package(ZeroMQ REQUIRED)
find_package(RapidJSON REQUIRED)

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

if (CROSSCOMPILE)
    message("TOOL CHAIN: windows")
#    SET(CMAKE_TOOLCHAIN_FILE ./cmake/x86_64.cmake)
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include
      ${SERIALPORT_INCLUDE_DIR}
      ${ZEROMQ_INCLUDE_DIR}
      ${EXT_LIBS_PATH}/zmq/include      # This is hack
      ${RAPIDJSON_INCLUDE_DIR}
)

add_library(connector
    src/Connector_Impl.cpp
    src/SerialConnector.cpp
    src/PubSubConnector.cpp
    src/RequestReplyConnector.cpp
    src/ZMQConnector.cpp
)

target_link_libraries(connector
      PUBLIC ${SERIALPORT_LIBRARIES}
      PUBLIC ${ZEROMQ_LIBRARIES}
      -lpthread
)

target_include_directories(connector
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC ${SERIALPORT_INCLUDE_DIR}
    PUBLIC ${EXT_LIBS_PATH}/zmq/include
    PUBLIC ${ZEROMQ_INCLUDE_DIR}
    PUBLIC ${RAPIDJSON_INCLUDE_DIR}
)
