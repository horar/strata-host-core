#
# Version CMake macro
#
# Create target per desired project to:
#   - generate version string via Git description (apps)
#   - generate macOS property info files(apps)
#   - generate Windows resource files(apps)
#   - generate version.json (components)
#
# Usage:
#   - call 'generate_app_version(GITTAG_PREFIX "devstudio_" MACBUNDLE ON)' after main target definition.
# or
#   - call 'generate_component_version(GITTAG_PREFIX sgwidgets_)' after 'qt5_add_binary_resources' CMake command.
#

option(BUILD_GITTAG_VERSION "Use project version string from Git tag" ON)
add_feature_info(BUILD_GITTAG_VERSION BUILD_GITTAG_VERSION "Use project version string from Git tag")


set(GIT_ROOT_DIR "${CMAKE_SOURCE_DIR}")
if(IS_DIRECTORY ${GIT_ROOT_DIR}/.git)
    find_package(Git 2.7 REQUIRED)
endif()


# 'tweak' number represend an build-id used by CI looks like Jenkins
if("$ENV{BUILD_ID}" STREQUAL "")
    set(BUILD_ID 1)
else()
    set(BUILD_ID $ENV{BUILD_ID})
endif()
message(STATUS "Build Id: ${BUILD_ID}")


macro(generate_app_version)
    set(options GITTAG_PREFIX MACBUNDLE)
    cmake_parse_arguments(local "" "${options}" "" ${ARGN})

    message(STATUS "Creating app version target for ${PROJECT_NAME} (prefix: '${local_GITTAG_PREFIX}')...")
    if(${PROJECT_NAME}_ENABLED_PLUGINS)
        list(JOIN ${PROJECT_NAME}_ENABLED_PLUGINS ":" SUPPORTED_PLUGINS)
        message(STATUS "Supported plugin list for ${PROJECT_NAME}: ${SUPPORTED_PLUGINS}")
    endif()

    add_custom_target(${PROJECT_NAME}_version ALL)
    add_custom_command(
        TARGET ${PROJECT_NAME}_version
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}

        COMMAND ${CMAKE_COMMAND}
            -DGIT_ROOT_DIR=${GIT_ROOT_DIR}
            -DGIT_EXECUTABLE=${GIT_EXECUTABLE}

            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}

            -DVERSION_FILES=Version.cpp\;Version.h

            -DINPUT_DIR=${CMAKE_SOURCE_DIR}/CMake/Templates
            -DWORKING_DIR=${CMAKE_CURRENT_BINARY_DIR}

            -DDEPLOYMENT_DIR=${CMAKE_BINARY_DIR}
            -DPROJECT_DIR=${CMAKE_CURRENT_SOURCE_DIR}

            -DUSE_GITTAG_VERSION=${BUILD_GITTAG_VERSION}

            -DPROJECT_NAME=${PROJECT_NAME}
            -DPROJECT_COMPANY=${PROJECT_COMPANY}
            -DPROJECT_COPYRIGHT=${PROJECT_COPYRIGHT}
            -DPROJECT_DESCRIPTION=${PROJECT_DESCRIPTION}
            -DPROJECT_MACBUNDLE=${local_MACBUNDLE}
            -DPROJECT_BUNDLE_ID=${PROJECT_BUNDLE_ID}
            -DPROJECT_WIN32_ICO=${PROJECT_WIN32_ICO}
            -DPROJECT_MACOS_ICNS=${PROJECT_MACOS_ICNS}
            -DPROJECT_VERSION_TWEAK=${BUILD_ID}
            -DPROJECT_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}

            -DGITTAG_PREFIX=${local_GITTAG_PREFIX}

            -DSUPPORTED_PLUGINS=${SUPPORTED_PLUGINS}

            -P ${CMAKE_SOURCE_DIR}/CMake/Modules/GitVersion-builder.cmake
            COMMENT "Analyzing git-tag version changes for '${PROJECT_NAME}'..." VERBATIM
    )

    add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_version)

    if(APPLE AND local_MACBUNDLE)
        add_custom_command(TARGET ${PROJECT_NAME}_version POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                ${CMAKE_CURRENT_BINARY_DIR}/Info.plist
                ${CMAKE_BINARY_DIR}/$<IF:$<CONFIG:OTA>,packages/${PROJECT_BUNDLE_ID}/data,bin>/${PROJECT_DESCRIPTION}.app/Contents/Info.plist
                COMMENT "Copying OS X Info.plist" VERBATIM
        )
    endif()
    if (WIN32)
        target_sources(${PROJECT_NAME} PRIVATE
            ${CMAKE_CURRENT_BINARY_DIR}/App.rc
        )
    set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/App.rc
            PROPERTIES GENERATED ON
        )
    endif()

    target_sources(${PROJECT_NAME} PRIVATE
        Version.cpp
    )
    set_source_files_properties(Version.cpp
        PROPERTIES GENERATED ON
        SKIP_AUTOMOC ON
    )
    set_source_files_properties(Version.h
        PROPERTIES GENERATED ON
    )
endmacro()

macro(generate_component_version)
    set(options GITTAG_PREFIX QRC_NAMESPACE)
    cmake_parse_arguments(local "" "${options}" "" ${ARGN})

    message(STATUS "Creating component version target for ${PROJECT_NAME} (prefix: '${local_GITTAG_PREFIX}')...")

    string(REPLACE "component-" "" COMPONENT_NS "${PROJECT_NAME}")
    string(REPLACE "views-" "" COMPONENT_NS "${COMPONENT_NS}")
    set(COMPONENT_NS_PREFIX ${local_QRC_NAMESPACE})
    configure_file(
        ${CMAKE_SOURCE_DIR}/CMake/Templates/version.qrc.in
        ${CMAKE_CURRENT_BINARY_DIR}/version.qrc
        @ONLY
    )
    string(FIND ${local_QRC_NAMESPACE} "/tech/strata" _isQmlModule)
    if (NOT ${_isQmlModule} EQUAL -1)
        set(${PROJECT_NAME}_input_file version-components.json)
    else()
        set(${PROJECT_NAME}_input_file version.json)
    endif()

    add_custom_target(${PROJECT_NAME}_version ALL)
    add_custom_command(
        TARGET ${PROJECT_NAME}_version
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}

        COMMAND ${CMAKE_COMMAND}
            -DGIT_ROOT_DIR=${GIT_ROOT_DIR}
            -DGIT_EXECUTABLE=${GIT_EXECUTABLE}

            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}

            -DVERSION_FILES=version.json

            -DINPUT_DIR=${CMAKE_SOURCE_DIR}/CMake/Templates
            -DWORKING_DIR=${CMAKE_CURRENT_BINARY_DIR}

            -DDEPLOYMENT_DIR=${CMAKE_BINARY_DIR}
            -DPROJECT_DIR=${CMAKE_CURRENT_SOURCE_DIR}

            -DUSE_GITTAG_VERSION=${BUILD_GITTAG_VERSION}

            -DPROJECT_NAME=${PROJECT_NAME}
            -DPROJECT_VERSION_TWEAK=${BUILD_ID}

            -DGITTAG_PREFIX=${local_GITTAG_PREFIX}

            -P ${CMAKE_SOURCE_DIR}/CMake/Modules/GitVersion-builder.cmake
            COMMENT "Analyzing git-tag version changes for '${PROJECT_NAME}'..." VERBATIM
    )

    add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_version)

    set_source_files_properties(version.json
        PROPERTIES GENERATED ON
    )
endmacro()

macro(generate_ifw_version)
    set(options GITTAG_PREFIX)
    cmake_parse_arguments(local "" "${options}" "" ${ARGN})

    if (NOT TARGET ${PROJECT_NAME}_version)
        message(STATUS "Creating version target for ${PROJECT_NAME} (prefix: '${local_GITTAG_PREFIX}')...")

        add_custom_target(${PROJECT_NAME}_version ALL)
        add_custom_command(
            TARGET ${PROJECT_NAME}_version
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}

            COMMAND ${CMAKE_COMMAND}
                -DGIT_ROOT_DIR=${GIT_ROOT_DIR}
                -DGIT_EXECUTABLE=${GIT_EXECUTABLE}

                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}

                -DVERSION_FILES=version.json
                -DINPUT_DIR=${CMAKE_SOURCE_DIR}/CMake/Templates
                -DWORKING_DIR=${CMAKE_CURRENT_BINARY_DIR}
                -DDEPLOYMENT_DIR=${CMAKE_BINARY_DIR}
                -DPROJECT_DIR=${CMAKE_CURRENT_SOURCE_DIR}

                -DUSE_GITTAG_VERSION=${BUILD_GITTAG_VERSION}


                -DPROJECT_NAME=${PROJECT_NAME}
                -DPROJECT_COMPANY=${PROJECT_COMPANY}
                -DPROJECT_COPYRIGHT=${PROJECT_COPYRIGHT}
                -DPROJECT_DESCRIPTION=${PROJECT_DESCRIPTION}
                -DPROJECT_BUNDLE_ID=${PROJECT_BUNDLE_ID}
                -DPROJECT_VERSION_TWEAK=${BUILD_ID}
                -DQT5_VERSION=${Qt5Core_VERSION_STRING}


                -DGITTAG_PREFIX=${local_GITTAG_PREFIX}

                -P ${CMAKE_SOURCE_DIR}/CMake/Modules/GitVersion-builder.cmake
                COMMENT "Analyzing git-tag version changes for ${PROJECT_NAME}..." VERBATIM
        )

        add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_version)

        set_source_files_properties(version.json
            PROPERTIES GENERATED ON
        )
    endif()
endmacro()
