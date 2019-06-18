project(component-pdfjs
    VERSION 0.0.0
    LANGUAGES NONE
)
message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

file(GLOB_RECURSE QRC_SRCS *.qrc)
add_custom_target(${PROJECT_NAME}-qrc-srcs SOURCES ${QRC_SRCS})
qt5_add_binary_resources(${PROJECT_NAME}
    ${QRC_SRCS}
    OPTIONS ARGS --compress 9 --threshold 0 --verbose
    DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}.rcc
)

include(MacroAddQmlImportPath)
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
