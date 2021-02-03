project(StrataRPC
    VERSION 0.1
    LANGUAGES CXX
)

set (SERVER ${PROJECT_NAME}-StrataServer)
set (CLIENT ${PROJECT_NAME}-StrataClient)
set (COMMON_LIB ${PROJECT_NAME}-CommonLib)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

# StrataRPC-CommonLib
# Added it to avoid duplicate symbols error when linking.
add_library(${COMMON_LIB}
    src/Dispatcher.cpp
    src/logging/LoggingQtCategories.cpp
)

target_include_directories(${COMMON_LIB}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${COMMON_LIB}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
)

set_target_properties(${COMMON_LIB} PROPERTIES
    AUTOMOC ON
)

target_compile_definitions(${COMMON_LIB} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)


#
# StrataRPC-Server
#
add_library(${SERVER}
    src/StrataServer.cpp
    src/Client.cpp
    src/ClientsController.cpp
    src/ServerConnector.cpp
    src/logging/LoggingQtCategories.cpp

    include/StrataRPC/StrataServer.h
)

add_library(strata::${SERVER} ALIAS ${SERVER})

target_include_directories(${SERVER}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${SERVER}
    PRIVATE ${COMMON_LIB}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
    PUBLIC strata::connector
)

set_target_properties(${SERVER} PROPERTIES
    AUTOMOC ON
)

target_compile_definitions(${SERVER} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)


#
# StrataRPC-Client
#
add_library(${CLIENT}
    src/StrataClient.cpp
    src/ClientConnector.cpp
    src/RequestsController.cpp
    src/PendingRequest.cpp
    src/logging/LoggingQtCategories.cpp

    include/StrataRPC/StrataClient.h
    include/StrataRPC/PendingRequest.h
)

add_library(strata::${CLIENT} ALIAS ${CLIENT})

target_include_directories(${CLIENT}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${CLIENT}
    PRIVATE ${COMMON_LIB}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
    PUBLIC strata::connector
)

set_target_properties(${CLIENT} PROPERTIES
    AUTOMOC ON
)

target_compile_definitions(${CLIENT} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

# StrataRPC tests
if(BUILD_TESTING)
    add_subdirectory(test)
endif()
