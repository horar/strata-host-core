project(connector
    VERSION 1.0
    LANGUAGES CXX
)

add_library(${PROJECT_NAME}
    src/Connector.cpp
    src/ZmqConnector.cpp
    src/ZmqRouterConnector.cpp
    src/ZmqDealerConnector.cpp
    src/ZmqPublisherConnector.cpp
    src/ZmqSubscriberConnector.cpp
    src/ZmqRequestConnector.cpp
    src/ZmqResponseConnector.cpp
    src/logging/LoggingQtCategories.cpp
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
      PUBLIC strata::QtLogger
      zeromq::libzmq
      zeromq::cppzmq
)

target_include_directories(${PROJECT_NAME}
    PUBLIC include
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
