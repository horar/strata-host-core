macro(add_view)
    set(projectName NAME)
    set(projectVersion VERSION)
    cmake_parse_arguments(local "" "${projectName}" "${projectVersion}" ${ARGN})

    if(NOT BUILD_VIEWS)
        mark_as_advanced(VIEWS_${local_NAME})
        return()
    endif()
    mark_as_advanced(CLEAR VIEWS_${local_NAME})

    message(STATUS "Strata view '${local_NAME}' v${local_VERSION}")

    option(VIEWS_${local_NAME} "Strata '${local_NAME}' v${local_VERSION} view" ON)
    add_feature_info(views-${local_NAME} VIEWS_${local_NAME} "Strata '${local_NAME}' v${local_VERSION} view")

    if(NOT ${VIEWS_${local_NAME}})
        file(REMOVE ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/views-${local_NAME}.rcc)
        return()
    endif()

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
