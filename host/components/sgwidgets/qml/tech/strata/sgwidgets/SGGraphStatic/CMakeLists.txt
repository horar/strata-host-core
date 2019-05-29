get_filename_component(ProjectId ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" ProjectId ${ProjectId})
project(SGWidgetsExample-${ProjectId} LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Widgets
    REQUIRED
)

add_sgwidget_example(
    NAME ${PROJECT_NAME}
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Widgets
)
