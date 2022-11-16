##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(lcuPlugin
    VERSION 0.0.0
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Qml
    REQUIRED
)

add_library(${PROJECT_NAME} MODULE
    ConfigFileSettings.cpp
    LogFilesCompress.cpp
    QtFilterRulesModel.cpp
    logconf_plugin.cpp
    qml.qrc

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/pluginLogger/qml.qrc
    qmldir
    qmldir-plugin
    plugins.qmltypes
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Core
    Qt5::Quick
    Qt5::Qml

    strata::QtLogger
    QuaZip::QuaZip
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
    AUTORCC ON
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<IF:$<CONFIG:OTA>,packages/${PROJECT_BUNDLE_ID}/data,bin>/imports/tech/strata/logconf
)

# Copy 'qmldir' and 'qmltypes' file next to plugin lib
add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_LIST_DIR}/qmldir-plugin
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/qmldir
    COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_LIST_DIR}/plugins.qmltypes
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/imports")
