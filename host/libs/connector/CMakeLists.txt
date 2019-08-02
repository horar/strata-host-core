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
    src/Connector.cpp
    src/SerialConnector.cpp
    src/ZmqConnector.cpp
    src/ZmqRouterConnector.cpp
    src/ZmqDealerConnector.cpp
    src/ZmqPublisherConnector.cpp
    src/ZmqSubscriberConnector.cpp
    src/ZmqRequestConnector.cpp
    src/ZmqResponseConnector.cpp
)

target_link_libraries(${PROJECT_NAME}
      PUBLIC ${SERIALPORT_LIBRARIES}
      PUBLIC ${ZEROMQ_LIBRARIES}
      Threads::Threads
)

target_include_directories(${PROJECT_NAME}
    PUBLIC include
    PUBLIC ${SERIALPORT_INCLUDE_DIR}
    PUBLIC ${EXT_LIBS_PATH}/zmq/include
    PUBLIC ${ZEROMQ_INCLUDE_DIR}
    PUBLIC ${RAPIDJSON_INCLUDE_DIR}
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
