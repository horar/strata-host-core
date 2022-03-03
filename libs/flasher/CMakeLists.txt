##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(Flasher
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

set(CONNECTOR_SUFFIX "Connector")

# Flasher

add_library(${PROJECT_NAME}
    src/Flasher.cpp
    src/logging/LoggingQtCategories.cpp
    #AUTOMOC wont find header if it is in different directory
    include/Flasher.h
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
    PUBLIC strata::Platform
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

# FlasherConnector

add_library(${PROJECT_NAME}${CONNECTOR_SUFFIX}
    src/FlasherConnector.cpp
    #AUTOMOC wont find header if it is in different directory
    include/FlasherConnector.h
)
add_library(strata::${PROJECT_NAME}${CONNECTOR_SUFFIX} ALIAS ${PROJECT_NAME}${CONNECTOR_SUFFIX})

target_include_directories(${PROJECT_NAME}${CONNECTOR_SUFFIX}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}${CONNECTOR_SUFFIX}
    PUBLIC Qt5::Core
    PUBLIC strata::${PROJECT_NAME}
)

target_compile_definitions(${PROJECT_NAME}${CONNECTOR_SUFFIX} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

set_target_properties(${PROJECT_NAME}${CONNECTOR_SUFFIX} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
