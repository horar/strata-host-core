# Create target per desired project to generate version string via Git description

set(GIT_ROOT_DIR "${CMAKE_SOURCE_DIR}/..")
if(IS_DIRECTORY ${GIT_ROOT_DIR}/.git)
    find_package(Git 2.7 REQUIRED)
endif()

macro(generate_version)
    if (NOT TARGET ${PROJECT_NAME}Version)
        message(STATUS "Creating version target for ${PROJECT_NAME}...")

        if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Version.h)
            file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Version.h
                "// WARNING! All changes made in this file will be lost!!\n\n"
                "#pragma once\n\n"
                "extern const char* const version;\n"
                "extern const char* const versionMajor;\n"
                "extern const char* const versionMinor;\n"
                "extern const char* const versionPatch;\n"
                "extern const char* const versionTweak;\n\n"
            )
        endif()

        add_custom_target(${PROJECT_NAME}_version ALL)
        add_custom_command(
            TARGET ${PROJECT_NAME}_version
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}

            COMMAND ${CMAKE_COMMAND}
                -DGIT_ROOT_DIR=${GIT_ROOT_DIR}
                -DGIT_EXECUTABLE=${GIT_EXECUTABLE}

                -DINPUT_DIR=${CMAKE_SOURCE_DIR}/CMake/Templates
                -DOUTPUT_DIR=${CMAKE_CURRENT_BINARY_DIR}

                -DPROJECT_NAME=${PROJECT_NAME}
                -DPROJECT_COMPANY=${PROJECT_COMPANY}
                -DPROJECT_COPYRIGHT=${PROJECT_COPYRIGHT}
                -DPROJECT_DESCRIPTION=${PROJECT_DESCRIPTION}
                -DPROJECT_WIN32_ICO=${PROJECT_WIN32_ICO}
                -DPROJECT_VERSION_TWEAK=${PROJECT_VERSION_TWEAK}

                -P ${CMAKE_SOURCE_DIR}/CMake/Includes/Version-builder.cmake
                COMMENT "Analyzing git-tag version changes for ${PROJECT_NAME}..." VERBATIM
        )

        set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Version.cpp
            PROPERTIES GENERATED ON
            SKIP_AUTOMOC ON
        )

        add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_version)

        if(APPLE)
            set_target_properties(${PROJECT_NAME} PROPERTIES
                MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist"
            )
        endif()
        if (WIN32)
            target_sources(${PROJECT_NAME} PRIVATE
                ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.rc
            )
            set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.rc
                PROPERTIES GENERATED ON
            )
        endif()
    endif()
endmacro()
