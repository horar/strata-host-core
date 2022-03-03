##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# spdlog
#

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/spdlog" "${EXTERN_INSTALL_DIR_PATH}/spdlog")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/spdlog-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/spdlog-${GIT_HASH}/lib)
    ExternalProject_Add(spdlog
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/spdlog-${GIT_HASH}
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/spdlog
        EXCLUDE_FROM_ALL ON
        CMAKE_ARGS "${CMAKE_ARGS}"
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DSPDLOG_BUILD_SHARED=off
            -DSPDLOG_BUILD_BENCH=off
            -DSPDLOG_BUILD_EXAMPLE=off
            -DSPDLOG_BUILD_TESTS=off
            -DSPDLOG_NO_EXCEPTIONS=on
    )
endif()

add_library(spdlog::spdlog INTERFACE IMPORTED GLOBAL)
set_target_properties(spdlog::spdlog PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/spdlog-${GIT_HASH}/include"
)
add_dependencies(spdlog::spdlog DEPENDS spdlog)
