project(sgwidgets
    VERSION 0.0.1.1
    DESCRIPTION "TODO"
    HOMEPAGE_URL "URL_ADDR"
    LANGUAGES CXX
)


set(QML_IMPORT_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}/qml
    ${CMAKE_CURRENT_BINARY_DIR}/imports
    CACHE string "Additional QML import paths" FORCE
)


add_library(${PROJECT_NAME} MODULE)
#add_library(${PROJECT_NAME} SHARED)

target_sources(${PROJECT_NAME}
    PRIVATE
    SgWidgetsPlugin.cpp

    # resources
    SgWidgetsPlugin.qrc

    ## It's not important to include 'qmldir' or 'plugin.qmltypes' here,
    ## but it will make IDEs (such as Qt Creator) to include them in project tree
    #qmldir
    #plugin.qmltypes
)

#target_compile_options(
#    ${PROJECT_NAME}
#    PRIVATE
#        -Wall
#        -Wextra
#        -Wpedantic
#)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt5::Core
        Qt5::Quick
        Qt5::Qml
)

## During plugin searching Qt will be looking for 'qmldir' file
## So we should place it next to our plugin lib.
#add_custom_command(
#    TARGET ${PROJECT_NAME}
#    POST_BUILD
#    COMMAND
#        ${CMAKE_COMMAND} -E copy
#        ${CMAKE_CURRENT_LIST_DIR}/qmldir
#        $<TARGET_FILE_DIR:${PROJECT_NAME}>/qmldir
#)

## FIXME: doesn't work on windows...
## install
#install(TARGETS ${PROJECT_NAME}
#    LIBRARY DESTINATION plugins/${PROJECT_NAME} COMPONENT ${PROJECT_NAME}
#)
