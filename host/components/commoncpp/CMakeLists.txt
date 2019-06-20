project(commoncpp
    VERSION 0.0.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick
    REQUIRED
)

add_library(${PROJECT_NAME} MODULE)

target_sources(${PROJECT_NAME}
    PRIVATE
    CommonCppPlugin.cpp
    SGUtilsCpp.cpp
    SGJLinkConnector.cpp
    logging/LoggingQtCategories.cpp

    imports/tech/strata/${PROJECT_NAME}/qmldir
    imports/tech/strata/${PROJECT_NAME}/plugins.qmltypes
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    Qt5::Core
    Qt5::Quick
    Qt5::Qml

    QtLogger
    )

set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    AUTOMOC ON
    AUTORCC ON
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/imports/tech/strata/${PROJECT_NAME}
)

# Copy 'qmldir' and 'qmltypes' file next to plugin lib
add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_LIST_DIR}/imports/tech/strata/${PROJECT_NAME}/qmldir
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/
    COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_LIST_DIR}/imports/tech/strata/${PROJECT_NAME}/plugins.qmltypes
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/
)

include(MacroAddQmlImportPath)
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/imports")
