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

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake/Modules")

include(SetupConfigurations)
include(FeatureSummary)
include(CMakeDependentOption)
include(SetupCompileOptions)

include(GitVersionMacro)
include(TimestampMacro)
include(ReplicatorCredentialsMacro)
include(AddQmlImportPathMacro)

# common for 'apps' and 'components' that use resource files
add_qml_import_path(PATH ":/")

if(CMAKE_BUILD_TYPE STREQUAL "OTA")
    add_custom_target(${PROJECT_NAME})
    generate_ifw_version(GITTAG_PREFIX "ifw_")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_BUILD_RPATH "${CMAKE_BINARY_DIR}/bin")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

set(CMAKE_VIEWS_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/views")
file(MAKE_DIRECTORY "${CMAKE_VIEWS_OUTPUT_DIRECTORY}")
set(CMAKE_PLUGINS_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/plugins")
file(MAKE_DIRECTORY "${CMAKE_PLUGINS_OUTPUT_DIRECTORY}")

option(BUILD_TESTING "Build the testing tree" ON)
add_feature_info(BUILD_TESTING BUILD_TESTING "Build the testing tree.")
enable_testing()

if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/strata-host-core-internal")
    add_subdirectory(strata-host-core-internal)
endif()

add_subdirectory(extern)
option(BUILD_EXAMPLES "Build project examples" OFF)
add_feature_info(BUILD_EXAMPLES BUILD_EXAMPLES "Build project examples")
add_subdirectory(components)
add_subdirectory(apps)
add_subdirectory(libs)

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
