##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(component-commoncpp
    VERSION 0.0.0
    LANGUAGES CXX
)

include(SubdirList)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Qml
    REQUIRED
)

add_library(${PROJECT_NAME} MODULE)

target_sources(${PROJECT_NAME}
    PRIVATE
    CommonCppPlugin.cpp
    mqtt/SGMqttClient.cpp
    mqtt/SGSslConfiguration.cpp

    imports/tech/strata/commoncpp/qmldir
    imports/tech/strata/commoncpp/plugins.qmltypes
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    Qt5::Core
    Qt5::Qml
    strata::SGUserSettings
    strata::SGUtilsCpp
    strata::SGQwtPlot
    strata::SGSortFilterProxyModel
    strata::SGVersionUtils
    strata::SGJLinkConnector
    strata::SGJsonSyntaxHighlighter
    strata::SGTextHighlighter
    strata::SGTranslator
    strata::SGConversion
    strata::SGCSVUtils
    mqtt::mqtt
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<IF:$<CONFIG:OTA>,packages/${PROJECT_BUNDLE_ID}/data,bin>/imports/tech/strata/commoncpp
)

# Copy 'qmldir' and 'qmltypes' file next to plugin lib
add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_LIST_DIR}/imports/tech/strata/commoncpp/qmldir
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/
    COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_LIST_DIR}/imports/tech/strata/commoncpp/plugins.qmltypes
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/
)

SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR})

foreach(SUBDIR ${SUBDIRS})
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SUBDIR}/CMakeLists.txt")
        add_subdirectory(${SUBDIR})
    endif()
endforeach()

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/imports")
