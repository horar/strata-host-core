project(sgwidgets
    VERSION 0.0.0
    LANGUAGES NONE
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

file(GLOB_RECURSE QRC_SRC *.qrc)
add_custom_target(src-qrcs SOURCES ${QRC_SRC})
qt5_add_binary_resources(${PROJECT_NAME}
    ${QRC_SRC}
    OPTIONS ARGS --compress 9 --threshold 0 --verbose
    DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}.rcc
)

# [LC] update QML mobule import paths for this project here
list(APPEND QML_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
list(APPEND QML_DIRS ":/")

# Additional import path used to resolve QML modules in Qt Creator's code model
set(QML_IMPORT_PATH "${QML_DIRS};${QML_IMPORT_PATH}"
    CACHE STRING "Qt Creator extra qml import paths" FORCE
)
