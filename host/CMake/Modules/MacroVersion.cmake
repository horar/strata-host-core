#
# Version CMake macro
#
# Create target per desired project to:
#   - generate version string via Git description (apps)
#   - generate macOS property info files(apps)
#   - generate Windows resource files(apps)
#
# Usage:
#   - call 'generate_app_version(GITTAG_PREFIX "devstudio_" MACBUNDLE ON)' after main target definition.
#

set(GIT_ROOT_DIR "${CMAKE_SOURCE_DIR}/..")
if(IS_DIRECTORY ${GIT_ROOT_DIR}/.git)
    find_package(Git 2.7 REQUIRED)
endif()


# 'tweak' number represend an build-id used by CI looks like Jenkins
if("$ENV{BUILD_ID}" STREQUAL "")
    set(VERSION_TWEAK 1)
else()
    set(VERSION_TWEAK $ENV{BUILD_ID})
endif()
message(STATUS "Build Id: ${VERSION_TWEAK}")


macro(generate_app_version)
    set(options GITTAG_PREFIX MACBUNDLE)
    cmake_parse_arguments(local "" "${options}" "" ${ARGN})

    if (NOT TARGET ${PROJECT_NAME}Version)
        message(STATUS "Creating version target for ${PROJECT_NAME} (prefix: '${local_GITTAG_PREFIX}')...")

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
                -DPROJECT_MACBUNDLE=${local_MACBUNDLE}
                -DPROJECT_BUNDLE_ID=${PROJECT_BUNDLE_ID}
                -DPROJECT_WIN32_ICO=${PROJECT_WIN32_ICO}
                -DPROJECT_MACOS_ICNS=${PROJECT_MACOS_ICNS}
                -DPROJECT_VERSION_TWEAK=${VERSION_TWEAK}
                -DPROJECT_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}

                -DGITTAG_PREFIX=${local_GITTAG_PREFIX}

                -P ${CMAKE_SOURCE_DIR}/CMake/Includes/Version-builder.cmake
                COMMENT "Analyzing git-tag version changes for ${PROJECT_NAME}..." VERBATIM
        )

        add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_version)

        if(APPLE AND local_MACBUNDLE)
            add_custom_command(TARGET ${PROJECT_NAME}_version POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist
                    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_DESCRIPTION}.app/Contents/Info.plist
                    COMMENT "Copying OS X Info.plist" VERBATIM
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

        target_sources(${PROJECT_NAME} PRIVATE
            ${PROJECT_NAME}Version.cpp
        )
        set_source_files_properties(${PROJECT_NAME}Version.cpp
            PROPERTIES GENERATED ON
            SKIP_AUTOMOC ON
        )
    endif()
endmacro()
