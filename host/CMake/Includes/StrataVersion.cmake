# Generate version string via Git description

set(GIT_ROOT_DIR "${CMAKE_SOURCE_DIR}/..")
if(IS_DIRECTORY ${GIT_ROOT_DIR}/.git)
    find_package(Git 2.7 REQUIRED)
endif()


add_custom_target(${PROJECT_NAME}_version ALL)
add_custom_command(
    TARGET ${PROJECT_NAME}_version
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}

    COMMAND ${CMAKE_COMMAND}
        -DGIT_ROOT_DIR=${GIT_ROOT_DIR}
        -DGIT_EXECUTABLE=${GIT_EXECUTABLE}

        -DINPUT_DIR=${CMAKE_CURRENT_SOURCE_DIR}
        -DOUTPUT_DIR=${CMAKE_CURRENT_BINARY_DIR}

        -DPROJECT_NAME=StrataVersion
        -DPROJECT_VERSION=${host_VERSION}
        -DPROJECT_VERSION_MAJOR=${host_VERSION_MAJOR}
        -DPROJECT_VERSION_MINOR=${host_VERSION_MINOR}
        -DPROJECT_VERSION_PATCH=${host_VERSION_PATCH}
        -DPROJECT_VERSION_TWEAK=${host_VERSION_TWEAK}

        -P ${CMAKE_SOURCE_DIR}/CMake/Includes/StrataVersion-builder.cmake
        COMMENT "Analyzing Git version/tag changes..." VERBATIM
)

add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_version)
