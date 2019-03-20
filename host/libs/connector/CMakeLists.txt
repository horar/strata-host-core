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
find_package(Threads REQUIRED)

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)


add_library(connector
    src/Connector_impl.cpp
    src/SerialConnector.cpp
    src/PubSubConnector.cpp
    src/RequestReplyConnector.cpp
    src/ZMQConnector.cpp
)

target_link_libraries(${PROJECT_NAME}
      PUBLIC ${SERIALPORT_LIBRARIES}
      PUBLIC ${ZEROMQ_LIBRARIES}
      Threads::Threads
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC ${SERIALPORT_INCLUDE_DIR}
    PUBLIC ${EXT_LIBS_PATH}/zmq/include
    PUBLIC ${ZEROMQ_INCLUDE_DIR}
    PUBLIC ${RAPIDJSON_INCLUDE_DIR}
)
