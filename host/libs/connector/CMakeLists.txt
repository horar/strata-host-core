project(connector
    VERSION 1.0
    LANGUAGES CXX
)

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
