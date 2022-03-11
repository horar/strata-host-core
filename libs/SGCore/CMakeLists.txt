##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(SGCore
    DESCRIPTION "sgcore"
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Qml Quick
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_library(${PROJECT_NAME}
    src/AppUi.cpp
    src/logging/LoggingQtCategories.cpp
   
    #AUTOMOC wont find header if it is in different directory
    include/SGCore/AppUi.h

    # qml-dev-studio-minimal.qrc
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::Qml
    PUBLIC Qt5::Quick

    PUBLIC strata::QtLogger
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)


target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    # AUTORCC ON
    # AUTORCC_OPTIONS "--compress;9"
    # OUTPUT_NAME "${PROJECT_DESCRIPTION}"
)

qt5_add_binary_resources(${PROJECT_DESCRIPTION}-errordialog
    qml-dev-studio-minimal.qrc
    OPTIONS ARGS --binary --compress 9 --threshold 0 --verbose
    DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_DESCRIPTION}-errordialog.rcc
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
