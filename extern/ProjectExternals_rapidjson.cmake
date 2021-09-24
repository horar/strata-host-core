##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# rapidjson
#

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/rapidjson" "${EXTERN_INSTALL_DIR_PATH}/rapidjson")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/rapidjson-${GIT_HASH}/include)
    ExternalProject_Add(rapidjson
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/rapidjson-${GIT_HASH}
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/rapidjson
        EXCLUDE_FROM_ALL ON
        CMAKE_ARGS "${CMAKE_ARGS}"
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DRAPIDJSON_BUILD_DOC=off
            -DRAPIDJSON_BUILD_EXAMPLES=off
            -DRAPIDJSON_BUILD_TESTS=off
    )
endif()

add_library(rapidjson::rapidjson INTERFACE IMPORTED GLOBAL)
set_target_properties(rapidjson::rapidjson PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/rapidjson-${GIT_HASH}/include"
)
add_dependencies(rapidjson::rapidjson DEPENDS rapidjson)
