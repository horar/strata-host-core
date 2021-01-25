project(connector
    VERSION 1.0
    LANGUAGES CXX
)

find_package(ZMQHelper REQUIRED)
find_package(Threads REQUIRED)

add_library(${PROJECT_NAME}
    src/Connector.cpp
    src/ZmqConnector.cpp
    src/ZmqRouterConnector.cpp
    src/ZmqDealerConnector.cpp
    src/ZmqPublisherConnector.cpp
    src/ZmqSubscriberConnector.cpp
    src/ZmqRequestConnector.cpp
    src/ZmqResponseConnector.cpp
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
      PUBLIC ${SERIALPORT_LIBRARIES}
      rapidjson::rapidjson
      Threads::Threads
      zeromq::libzmq
      ZMQHelper
)

target_include_directories(${PROJECT_NAME}
    PUBLIC include
    PUBLIC ${SERIALPORT_INCLUDE_DIR}
    PUBLIC ${RAPIDJSON_INCLUDE_DIR}
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
