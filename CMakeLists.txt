##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
cmake_minimum_required(VERSION 3.19 FATAL_ERROR)

message(STATUS "CMake version: ${CMAKE_VERSION}")

if(APPLE AND NOT CMAKE_OSX_DEPLOYMENT_TARGET)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "" FORCE)
endif()

project(host
    DESCRIPTION "Strata"
    HOMEPAGE_URL "https://www.onsemi.com/strata"
    LANGUAGES CXX
)

set(VERSION_QT5 5.12)
set(VERSION_QT5_DEPRECATE_BEFORE 0x050C00)

# defaults; override in sub-projects if necessary
set(PROJECT_COMPANY "ON Semiconductor")
set(PROJECT_WIN32_ICO ${PROJECT_SOURCE_DIR}/resources/icons/app/on.ico)
set(PROJECT_BUNDLE_ID com.onsemi.strata)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Git)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/strata-cmake-modules/Modules")

include(SetupConfigurations)
include(FeatureSummary)
include(CMakeDependentOption)
include(SetupCompileOptions)

include(GitVersionMacro)
include(TimestampMacro)
include(ReplicatorCredentialsMacro)
include(AddQmlImportPathMacro)
include(DeployConfigFilesHelpers)

# common for 'apps' and 'components' that use resource files
add_qml_import_path(PATH ":/")

if(CMAKE_BUILD_TYPE STREQUAL "OTA")
    add_custom_target(${PROJECT_NAME})
    generate_ifw_version(GITTAG_PREFIX "ifw_")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_BUILD_RPATH "${CMAKE_BINARY_DIR}/bin")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

set(CMAKE_PLUGINS_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/plugins")
file(MAKE_DIRECTORY "${CMAKE_PLUGINS_OUTPUT_DIRECTORY}")

option(BUILD_TESTING "Build the testing tree" ON)
add_feature_info(BUILD_TESTING BUILD_TESTING "Build the testing tree.")
enable_testing()

option(BUILD_EXAMPLES "Build project examples" OFF)
add_feature_info(BUILD_EXAMPLES BUILD_EXAMPLES "Build project examples")

option(BUILD_BENCHMARK "Build project benchmark" OFF)
add_feature_info(BUILD_BENCHMARK BUILD_BENCHMARK "Build project benchmark")

option(APPS_UTILS "Build project supplementary utils" ON)
add_feature_info(APPS_UTILS APPS_UTILS "Build project supplementary utils")

if(NOT STRATA_HOST_CORE_INTERNAL_PATH)
    set(STRATA_HOST_CORE_INTERNAL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../strata-host-core-internal")
endif()

if(IS_DIRECTORY "${STRATA_HOST_CORE_INTERNAL_PATH}")
    add_subdirectory("${STRATA_HOST_CORE_INTERNAL_PATH}" "${CMAKE_BINARY_DIR}/strata-host-core-internal")
endif()

if(NOT STRATA_PLATFORM_CONTROL_VIEWS)
    set(STRATA_PLATFORM_CONTROL_VIEWS "${CMAKE_CURRENT_SOURCE_DIR}/../strata-platform-control-views")
endif()

if(IS_DIRECTORY "${STRATA_PLATFORM_CONTROL_VIEWS}")
    add_subdirectory("${STRATA_PLATFORM_CONTROL_VIEWS}" "${CMAKE_BINARY_DIR}/strata-platform-control-views")
endif()

# Note: please be careful with following subdirectory order; there are dependencies!
add_subdirectory(extern)
add_subdirectory(apps)
add_subdirectory(libs)
add_subdirectory(utils)
add_subdirectory(components)

message(STATUS "=============================================================================")
message(STATUS "QML import paths:")
foreach(QML_PATH IN LISTS QML_IMPORT_PATH)
    message(STATUS "\t${QML_PATH}")
endforeach()
message(STATUS "Project generator: ${CMAKE_GENERATOR}")
if(CMAKE_EXTRA_GENERATOR)
    message(STATUS "Project extra generator: ${CMAKE_EXTRA_GENERATOR}")
endif()
message(STATUS "=============================================================================")
feature_summary(WHAT ALL)
