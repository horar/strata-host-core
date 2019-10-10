project(updates
    VERSION 0.0.1.1
    DESCRIPTION "TODO"
    HOMEPAGE_URL "URL_ADDR"
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME}-plugin-test
    main.cpp
    Green.cpp

    EnhancedQmlApplicationEngine.cpp
)
target_link_libraries(${PROJECT_NAME}-plugin-test
    PRIVATE
        Qt5::Core
        Qt5::Quick
        Qt5::Qml
)


add_library(${PROJECT_NAME} MODULE)
#add_library(${PROJECT_NAME} SHARED)

target_sources(${PROJECT_NAME}
    PRIVATE
    UpdatesPlugin.cpp

    # resources
    UpdatesPlugin.qrc

    # It's not important to include 'qmldir' or 'plugin.qmltypes' here,
    # but it will make IDEs (such as Qt Creator) to include them in project tree
    qmldir
    plugin.qmltypes
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

# During plugin searching Qt will be looking for 'qmldir' file
# So we should place it next to our plugin lib.
add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND
        ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_LIST_DIR}/qmldir
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/qmldir
)

# FIXME: doesn't work on windows...
# install
install(TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION plugins/${PROJECT_NAME} COMPONENT ${PROJECT_NAME}
)
