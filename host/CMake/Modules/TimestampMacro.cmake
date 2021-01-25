#
# Timestamp CMMake macro
#
# Usage:
#   - call 'generate_app_build_timestamp()' after main target definition.
#

macro(generate_app_build_timestamp)
    if (NOT TARGET ${PROJECT_NAME}_timestamp)
        message(STATUS "Creating timestamp target for '${PROJECT_NAME}'...")

        if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/Timestamp.h)
            file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/Timestamp.h
                "// !! WARNING !!\n"
                "// Generated file. All changes made in this file will be lost!!\n\n"
                "#pragma once\n\n"
                "#include <string_view>\n\n"
                "struct Timestamp final {\n"
                "    static const std::string_view buildTimestamp;\n"
                "    static const std::string_view buildOnHost;\n"
                "};\n"
            )
        endif()
        add_custom_target(${PROJECT_NAME}_timestamp ALL)
        add_custom_command(
            TARGET ${PROJECT_NAME}_timestamp
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMAND ${CMAKE_COMMAND}
                -DPROJECT_NAME=${PROJECT_NAME}
                -DBUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DINPUT_DIR=${CMAKE_SOURCE_DIR}/CMake/Templates
                -DOUTPUT_DIR=${CMAKE_CURRENT_BINARY_DIR}
                -P ${CMAKE_SOURCE_DIR}/CMake/Modules/Timestamp-builder.cmake
            COMMENT "Generating build timestamp for '${PROJECT_NAME}'..." VERBATIM
        )

        add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_timestamp)

        target_sources(${PROJECT_NAME} PRIVATE
            Timestamp.cpp
        )
        set_source_files_properties(Timestamp.cpp
            PROPERTIES GENERATED ON
            SKIP_AUTOMOC ON
        )
        set_source_files_properties(Timestamp.h
            PROPERTIES GENERATED ON
        )
    endif()
endmacro()
