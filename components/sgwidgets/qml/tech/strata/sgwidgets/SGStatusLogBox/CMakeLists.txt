get_filename_component(ProjectId ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" ProjectId ${ProjectId})
project(SGWidgetsExample-${ProjectId} LANGUAGES CXX)

add_sgwidget_example(
    NAME ${PROJECT_NAME}
)
