##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(PlatformInterface
    VERSION 1.0.0
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/CoreInterface.cpp
    src/LoggingQtCategories.cpp
    # This is to let CMake know to run moc preprocessor on header files
    # with Q_OBJECT macro.
    include/PlatformInterface/core/CoreInterface.h
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC strata::StrataRPC-StrataClient
    PRIVATE strata::QtLogger
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/PlatformInterface
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

if(APPS_FEATURE_BLE)
    add_compile_definitions(APPS_FEATURE_BLE=true)
endif()
