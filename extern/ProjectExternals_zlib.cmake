##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# zlib - required for Quazip, need to build on windows
#

if(WIN32)
    get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/Zlib" "${EXTERN_INSTALL_DIR_PATH}/Zlib")
    if(NOT LIB_INSTALLED)
        file(MAKE_DIRECTORY "${EXTERN_INSTALL_DIR_PATH}/Zlib-${GIT_HASH}/include")
        ExternalProject_Add(Zlib
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/Zlib-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/Zlib
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DQt5_DIR=${Qt5_DIR}
        )
    endif()

    add_library(ZLIB::ZLIB STATIC IMPORTED GLOBAL)

    set_target_properties(ZLIB::ZLIB PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/Zlib-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/Zlib-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Zlib${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG  "${EXTERN_INSTALL_DIR_PATH}/Zlib-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Zlibd${CMAKE_STATIC_LIBRARY_SUFFIX}"
        ZLIB_ROOT_3P "${EXTERN_INSTALL_DIR_PATH}/Zlib-${GIT_HASH}"
    )

    add_dependencies(ZLIB::ZLIB DEPENDS Zlib)
endif()
