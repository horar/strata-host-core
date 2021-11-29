##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(component-sgwidgets
    LANGUAGES NONE
)
message(STATUS "${PROJECT_NAME}...")

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

file(GLOB_RECURSE QRC_SRCS qml.qrc)
list(APPEND QRC_SRCS "${CMAKE_CURRENT_BINARY_DIR}/version.qrc")

add_subdirectory(tech/strata/sgwidgets.1.0/debug.1.0)
list(APPEND QRC_SRCS "${SGDEBUG_DIR}/qml-plugin-qmldebug-static.qrc")
add_qml_debug_plugin(PLUGIN_NAME "qmldebug")

add_custom_target(${PROJECT_NAME}_qrcs SOURCES ${QRC_SRCS})
qt5_add_binary_resources(${PROJECT_NAME}
    ${QRC_SRCS}
    OPTIONS ARGS --compress 9 --threshold 0 --verbose
    DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}.rcc
)

if (CMAKE_BUILD_TYPE STREQUAL "OTA")
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}.rcc
            ${CMAKE_BINARY_DIR}/$<IF:$<CONFIG:OTA>,packages/${PROJECT_BUNDLE_ID}/data,bin>/${PROJECT_NAME}.rcc
        COMMENT "Deploying '${PROJECT_NAME}.rcc'..."
        VERBATIM
    )
endif()

generate_component_version(GITTAG_PREFIX sgwidgets_ QRC_NAMESPACE "/tech/strata")

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
