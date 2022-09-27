##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
option(BUILD_DONT_CLEAN_EXTERNAL "Don't clean external project (Makefile only)" ON)
add_feature_info(BUILD_DONT_CLEAN_EXTERNAL BUILD_DONT_CLEAN_EXTERNAL "Don't clean external project (Makefile only)")
set_directory_properties(PROPERTIES CLEAN_NO_CUSTOM ${BUILD_DONT_CLEAN_EXTERNAL})

include(ExternalProject)
include(GitHashAndInstallationStatus)

# root of all 3rd party installed project
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(EXTERN_INSTALL_DIR_NAME 3p-d)
else()
    set(EXTERN_INSTALL_DIR_NAME 3p)
endif()

if(EXTERN_INSTALL_DIR_PATH)
    if(NOT ${EXTERN_INSTALL_DIR_PATH} MATCHES ${EXTERN_INSTALL_DIR_NAME})
        string(APPEND EXTERN_INSTALL_DIR_PATH "/${EXTERN_INSTALL_DIR_NAME}")
    endif()
    message(STATUS "EXTERN_INSTALL_DIR_PATH is : ${EXTERN_INSTALL_DIR_PATH}")
else()
    set(EXTERN_INSTALL_DIR_PATH ${CMAKE_BINARY_DIR}/${EXTERN_INSTALL_DIR_NAME} CACHE PATH "" FORCE)
    message(STATUS "EXTERN_INSTALL_DIR_PATH is : ${EXTERN_INSTALL_DIR_PATH}")
endif()

# root of all 3rd party project (git submodules)
set(SOURCE_DIR_EXTERN ${CMAKE_SOURCE_DIR}/extern)

if(CMAKE_BUILD_TYPE STREQUAL "OTA")
    set(CMAKE_BUILD_TYPE_EXTERNAL_PROJECT Release)
else()
    set(CMAKE_BUILD_TYPE_EXTERNAL_PROJECT ${CMAKE_BUILD_TYPE})
endif()


# update common CMake flags that will be forwarded to external projects
list(APPEND CMAKE_ARGS "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE_EXTERNAL_PROJECT}")
list(APPEND CMAKE_ARGS "-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}")
list(APPEND CMAKE_ARGS "-DCMAKE_VERBOSE_MAKEFILE:BOOL=${CMAKE_VERBOSE_MAKEFILE}")
if(APPLE)
    list(APPEND CMAKE_ARGS "-DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}")
endif()
list(APPEND CMAKE_ARGS "-DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}")
list(APPEND CMAKE_ARGS "-DCMAKE_CXX_STANDARD:STRING=17")
list(APPEND CMAKE_ARGS "-DCMAKE_CXX_STANDARD_REQUIRED:BOOL=ON")
list(APPEND CMAKE_ARGS "-DCMAKE_CXX_EXTENSIONS:BOOL=OFF")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

include(ProjectExternals_rapidjson)
include(ProjectExternals_spdlog)
include(ProjectExternals_pdfjs)
include(ProjectExternals_googletest)
include(ProjectExternals_OpenSSL)
include(ProjectExternals_qwt)
include(ProjectExternals_cbl-official-api)
include(ProjectExternals_libzmq)
include(ProjectExternals_monaco_editor)
include(ProjectExternals_cppzmq)
include(ProjectExternals_zlib)
include(ProjectExternals_quazip)
