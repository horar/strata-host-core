##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# zlib
#
get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/zlib" "${EXTERN_INSTALL_DIR_PATH}/zlib")
ExternalProject_Add(zlib
    INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/zlib-${GIT_HASH}
    SOURCE_DIR ${SOURCE_DIR_EXTERN}/zlib
    EXCLUDE_FROM_ALL ON
    CMAKE_ARGS "${CMAKE_ARGS}"
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DQt5_DIR=${Qt5_DIR}
)

add_library(ZLIB::ZLIB INTERFACE IMPORTED GLOBAL)

set_target_properties(ZLIB::ZLIB PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/zlib-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/zlib-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlib${CMAKE_STATIC_LIBRARY_SUFFIX}"
    IMPORTED_LOCATION_DEBUG  "${EXTERN_INSTALL_DIR_PATH}/zlib-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlib${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_dependencies(ZLIB::ZLIB DEPENDS ZLIB)
