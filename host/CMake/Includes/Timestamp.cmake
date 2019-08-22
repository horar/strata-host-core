add_custom_target(${PROJECT_NAME}_timestamp ALL)
add_custom_command(
    TARGET ${PROJECT_NAME}_timestamp
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND}
        -DPROJECT_NAME=${PROJECT_NAME}
        -DBUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DINPUT_DIR=${CMAKE_CURRENT_SOURCE_DIR}
        -DOUTPUT_DIR=${CMAKE_CURRENT_BINARY_DIR}
        -P ${CMAKE_SOURCE_DIR}/CMake/Includes/Timestamp-builder.cmake
    COMMENT "Generating build timestamp for ${PROJECT_NAME}..." VERBATIM
)

add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_timestamp)
