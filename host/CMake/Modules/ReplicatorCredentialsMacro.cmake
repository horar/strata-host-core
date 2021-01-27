#
# ReplicatorCredentials CMMake macro
#
# Usage:
#   - call 'generate_app_build_replicator_credentials()' after main target definition.
#

macro(generate_app_build_replicator_credentials)
    set(options USERNAME PASSWORD)
    cmake_parse_arguments(local "" "${options}" "" ${ARGN})

    if (NOT TARGET ${PROJECT_NAME}_replicator_credentials)
        message(STATUS "Creating replicator credentials target for '${PROJECT_NAME}'...")

        if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/ReplicatorCredentials.h)
            file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/ReplicatorCredentials.h
                "// WARNING! Generated file.\n"
                "// All changes made in this file will be lost!!\n\n"
                "#pragma once\n\n"
                "#include <string_view>\n\n"
                "struct ReplicatorCredentials final {\n"
                "    static const std::string_view replicator_username;\n"
                "    static const std::string_view replicator_password;\n"
                "};\n\n"
            )
        endif()
        add_custom_target(${PROJECT_NAME}_replicator_credentials ALL)
        add_custom_command(
            TARGET ${PROJECT_NAME}_replicator_credentials
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMAND ${CMAKE_COMMAND}
                -DPROJECT_NAME=${PROJECT_NAME}
                -DBUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DINPUT_DIR=${CMAKE_SOURCE_DIR}/CMake/Templates
                -DOUTPUT_DIR=${CMAKE_CURRENT_BINARY_DIR}
                -DUSERNAME=${local_USERNAME}
                -DPASSWORD=${local_PASSWORD}
                -P ${CMAKE_SOURCE_DIR}/CMake/Modules/ReplicatorCredentials-builder.cmake
            COMMENT "Generating build replicator credentials for '${PROJECT_NAME}'..." VERBATIM
        )

        add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_replicator_credentials)

        target_sources(${PROJECT_NAME} PRIVATE
            ReplicatorCredentials.cpp
        )
        set_source_files_properties(ReplicatorCredentials.cpp
            PROPERTIES GENERATED ON
            SKIP_AUTOMOC ON
        )
    endif()
endmacro()
