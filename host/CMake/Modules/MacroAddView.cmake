macro(add_view)
    set(projectName NAME)
    cmake_parse_arguments(local "" "${projectName}" "" ${ARGN})

    cmake_dependent_option(VIEWS_${local_NAME} "Strata '${local_NAME}' view" ON
                           "BUILD_VIEWS" OFF)
    add_feature_info(views-${local_NAME} VIEWS_${local_NAME} "Strata '${local_NAME}' view")

    if(NOT BUILD_VIEWS)
        return()
    endif()

    if(NOT ${VIEWS_${local_NAME}})
        file(REMOVE ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/views-${local_NAME}.rcc)
        return()
    endif()

    message(STATUS "Strata view '${local_NAME}'...")

    file(GLOB_RECURSE QRC_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/qml-*.qrc)
    add_custom_target(${local_NAME}-qrc-srcs SOURCES ${QRC_SRCS})
    qt5_add_binary_resources(views-${local_NAME}
        ${QRC_SRCS}
        OPTIONS ARGS --compress 9 --threshold 0 --verbose
        DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/views-${local_NAME}.rcc
    )

    ## [LC] update QML mobule import paths for this project here
    #list(APPEND QML_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
    #
    ## Additional import path used to resolve QML modules in Qt Creator's code model
    #set(QML_IMPORT_PATH "${QML_DIRS};${QML_IMPORT_PATH}"
    #    CACHE STRING "Qt Creator extra qml import paths" FORCE
    #)
endmacro()
