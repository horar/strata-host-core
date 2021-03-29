macro(add_sds_plugin)
    set(options PROJ_NAME PLUGIN_OPTION_SUFFIX PLUGIN_NAME)
    cmake_parse_arguments(local "" "${options}" "" ${ARGN})

    target_sources(${local_PROJ_NAME} PRIVATE
        qml-dev-studio-plugin-${local_PLUGIN_NAME}-static.qrc
    )

    if(NOT APPS_CORESW_SDS OR NOT ${APPS_CORESW_SDS_PLUGIN_${local_PLUGIN_OPTION_SUFFIX}})
        if(EXISTS ${CMAKE_PLUGINS_OUTPUT_DIRECTORY}/sds-${local_PLUGIN_NAME}.rcc)
            message(STATUS "...removing 'sds-${local_PLUGIN_NAME}.rcc' plugin")
            file(REMOVE ${CMAKE_PLUGINS_OUTPUT_DIRECTORY}/sds-${local_PLUGIN_NAME}.rcc)
        endif()
    else()
        message(STATUS "Strata DevStudio plugin '${local_PLUGIN_NAME}'...")

        list(APPEND ${local_PROJ_NAME}_ENABLED_PLUGINS ${local_PLUGIN_NAME})

        set(PLUGIN_QRC_FILENAME qml-dev-studio-plugin-${local_PLUGIN_NAME}.qrc)
        add_custom_target(${local_PROJ_NAME}-plugin-${local_PLUGIN_NAME}
            SOURCES ${PLUGIN_QRC_FILENAME}
        )
        qt5_add_binary_resources(${local_PROJ_NAME}-plugin-${local_PLUGIN_NAME}-rcc
            ${PLUGIN_QRC_FILENAME}
            OPTIONS ARGS --compress 9 --threshold 0 --verbose
            DESTINATION ${CMAKE_PLUGINS_OUTPUT_DIRECTORY}/sds-${local_PLUGIN_NAME}.rcc
        )
        add_dependencies(${local_PROJ_NAME} ${local_PROJ_NAME}-plugin-${local_PLUGIN_NAME}-rcc)
    endif()
endmacro()
