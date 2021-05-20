function(find_all_config_files PATHS_LIST FILE_PATTERN FILE_LIST)
    foreach(CONFIG_PATH IN LISTS PATHS_LIST)
        file(GLOB TEMP_LIST
            RELATIVE ${CONFIG_PATH}
            ${CONFIG_PATH}/${FILE_PATTERN}
        )
        message("looking in ${CONFIG_PATH}")
        message("found ${TEMP_LIST}")
        list(APPEND TEMP_FILES_LIST ${TEMP_LIST})
    endforeach()
    message("done. found ${TEMP_FILES_LIST}")
    set(${FILE_LIST} ${TEMP_FILES_LIST} PARENT_SCOPE)
endfunction(find_all_config_files)

function(deploy_config_file PATHS_LIST CONFIG_FILE_NAME TARGET_CONFIG_NAME)
    find_file(CONFIG_ABSOLUTE_PATH 
        NAMES "${CONFIG_FILE_NAME}"
        PATHS ${PATHS_LIST}
        NO_DEFAULT_PATH
        REQUIRED
    )

    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CONFIG_ABSOLUTE_PATH}
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/${TARGET_CONFIG_NAME}
        COMMENT "Deploying '${TARGET_CONFIG_NAME}'..."
        VERBATIM
    )
endfunction(deploy_config_file)
