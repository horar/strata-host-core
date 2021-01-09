project(StrataRPC
    VERSION 0.1
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/StrataServer.cpp
    src/StrataClient.cpp
    src/Dispatcher.cpp
    src/Client.cpp
    src/ClientsController.cpp
    src/ServerConnector.cpp
    src/ClientConnector.cpp
    src/RequestsController.cpp
    src/logging/LoggingQtCategories.cpp

    include/StrataServer.h
    include/StrataClient.h
    include/Dispatcher.h
    include/ClientsController.h
    include/ServerConnector.h
    include/ClientConnector.h
    include/RequestsController.h
)

add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
    strata::connector
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
