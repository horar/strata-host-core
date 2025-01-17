##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(StrataRPC
    VERSION 0.1
    LANGUAGES CXX
)

set (SERVER ${PROJECT_NAME}-StrataServer)
set (CLIENT ${PROJECT_NAME}-StrataClient)
set (COMMON ${PROJECT_NAME}-Common)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

#
# StrataRPC-Common
#
add_library(${COMMON}
    src/RpcError.cpp
    include/StrataRPC/RpcError.h
)

add_library(strata::${COMMON} ALIAS ${COMMON})

target_include_directories(${COMMON}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${COMMON}
    PUBLIC Qt5::Core
)

set_target_properties(${COMMON} PROPERTIES
    AUTOMOC ON
)

target_compile_definitions(${COMMON} PRIVATE
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
    src/Dispatcher.h
    src/RpcRequest.cpp

    include/StrataRPC/StrataServer.h
    include/StrataRPC/RpcRequest.h
)

add_library(strata::${SERVER} ALIAS ${SERVER})

target_include_directories(${SERVER}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${SERVER}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
    PUBLIC strata::connector
    PUBLIC ${COMMON}
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
    src/DeferredReply.cpp
    src/logging/LoggingQtCategories.cpp

    include/StrataRPC/StrataClient.h
    include/StrataRPC/DeferredReply.h
)

add_library(strata::${CLIENT} ALIAS ${CLIENT})

target_include_directories(${CLIENT}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${CLIENT}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
    PUBLIC strata::connector
    PUBLIC ${COMMON}
)

set_target_properties(${CLIENT} PROPERTIES
    AUTOMOC ON
)

target_compile_definitions(${CLIENT} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()

if(BUILD_BENCHMARK)
    add_subdirectory(benchmark)
endif()
