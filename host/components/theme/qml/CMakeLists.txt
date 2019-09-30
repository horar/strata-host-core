project(component-theme
    LANGUAGES NONE
)
message(STATUS "${PROJECT_NAME}...")

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

file(GLOB_RECURSE QRC_SRCS *.qrc)
list(APPEND QRC_SRCS "${CMAKE_CURRENT_BINARY_DIR}/version.qrc")

add_custom_target(${PROJECT_NAME}_qrcs SOURCES ${QRC_SRCS})
qt5_add_binary_resources(${PROJECT_NAME}
    ${QRC_SRCS}
    OPTIONS ARGS --compress 9 --threshold 0 --verbose
    DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}.rcc
)

generate_component_version(GITTAG_PREFIX theme_ QRC_NAMESPACE "/tech/strta")

include(MacroAddQmlImportPath)
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
