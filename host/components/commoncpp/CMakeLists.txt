project(component-commoncpp
    VERSION 0.0.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Widgets
    REQUIRED
)

add_library(${PROJECT_NAME} MODULE)

target_sources(${PROJECT_NAME}
    PRIVATE
    CommonCppPlugin.cpp
    SGUtilsCpp.cpp
    SGJLinkConnector.cpp
    SGSortFilterProxyModel.cpp
    logging/LoggingQtCategories.cpp
    SGQWTPlot.cpp

    imports/tech/strata/commoncpp/qmldir
    imports/tech/strata/commoncpp/plugins.qmltypes
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    Qt5::Core
    Qt5::Quick
    Qt5::Qml
    Qt5::Widgets
    qwt::qwt
    QtLogger
    )

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/imports/tech/strata/commoncpp
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

# Export SGJLinkConnector
add_library(SGJLinkConnector
    SGJLinkConnector.cpp
    SGJLinkConnector.h
    logging/LoggingQtCategories.cpp
)

target_link_libraries(SGJLinkConnector
    PRIVATE
    Qt5::Core
    QtLogger
)

target_include_directories(SGJLinkConnector
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

set_target_properties(SGJLinkConnector PROPERTIES
    AUTOMOC ON
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/imports")
