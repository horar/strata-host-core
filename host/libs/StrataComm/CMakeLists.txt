project(StrataComm
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
    src/logging/LoggingQtCatagories.cpp
)

add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
