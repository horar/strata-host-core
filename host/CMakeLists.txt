cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

message(STATUS "CMake version: ${CMAKE_VERSION}")

if(APPLE AND NOT CMAKE_OSX_DEPLOYMENT_TARGET)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "" FORCE)
endif()

project(host
    LANGUAGES CXX
)

set(VERSION_QT5 5.12)

# defaults; override in sub-projects if necessary
set(PROJECT_COMPANY "ON Semiconductor")
set(PROJECT_WIN32_ICO ${PROJECT_SOURCE_DIR}/resources/icons/app/on.ico)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake/Modules")

option(BUILD_TESTING "Build the testing tree." ON)
enable_testing()

include(FeatureSummary)
include(SetupCompileOptions)

include(GitVersionMacro)
include(TimestampMacro)
include(AddQmlImportPathMacro)

# common for 'apps' and 'components' that use resource files
add_qml_import_path(PATH ":/")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

add_subdirectory(libs)
add_subdirectory(apps)
if(BUILD_TESTING)
    add_subdirectory(test)
endif()
add_subdirectory(extern)
add_subdirectory(samples)
option(BUILD_EXAMPLES "Build project examples" OFF)
add_feature_info(BUILD_EXAMPLES BUILD_EXAMPLES "Build project examples")
option(BUILD_UTILS "Build project suplementary utils" ON)
add_feature_info(BUILD_UTILS BUILD_UTILS "Build project suplementary utils")
if(BUILD_UTILS)
    add_subdirectory(utils)
endif()
add_subdirectory(components)
add_subdirectory(research_spikes)

message(STATUS "=============================================================================")
message(STATUS "QML import paths:")
foreach(QML_PATH IN LISTS QML_IMPORT_PATH)
    message(STATUS "\t${QML_PATH}")
endforeach()
message(STATUS "=============================================================================")
feature_summary(WHAT ALL)
