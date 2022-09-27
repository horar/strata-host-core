##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
#
# QuaZip (file compression into .zip archive)
#
if(WIN32)
    get_target_property(ZLIB_ROOT ZLIB::ZLIB ROOT_LOCATION)
    message(STATUS "'ZLIB_ROOT' set to: ${ZLIB_ROOT}")
endif()

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/quazip" "${EXTERN_INSTALL_DIR_PATH}/quazip")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY "${EXTERN_INSTALL_DIR_PATH}/quazip-${GIT_HASH}/include//QuaZip-Qt5-1.3")
    if(WIN32)
        ExternalProject_Add(QuaZip
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/quazip-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/quazip
            EXCLUDE_FROM_ALL ON
            DEPENDS Zlib
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DQt5_DIR=${Qt5_DIR}
                -DQUAZIP_ENABLE_TESTS=OFF
                -DQT_VERSION_MAJOR=5
                -DZLIB_ROOT=${ZLIB_ROOT}
        )
    else()
        ExternalProject_Add(QuaZip
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/quazip-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/quazip
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DQt5_DIR=${Qt5_DIR}
                -DQUAZIP_ENABLE_TESTS=OFF
                -DQT_VERSION_MAJOR=5
        )
    endif()
endif()

add_library(QuaZip::QuaZip STATIC IMPORTED GLOBAL)

set_target_properties(QuaZip::QuaZip PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "QUAZIP_STATIC"
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/quazip-${GIT_HASH}/include//QuaZip-Qt5-1.3"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/quazip-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}quazip1-qt5${CMAKE_STATIC_LIBRARY_SUFFIX}"
    IMPORTED_LOCATION_DEBUG  "${EXTERN_INSTALL_DIR_PATH}/quazip-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}quazip1-qt5d${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_dependencies(QuaZip::QuaZip DEPENDS QuaZip)

if(APPLE)
    target_link_libraries(QuaZip::QuaZip INTERFACE z ${FOUNDATION_LIB})
endif()

if(WIN32)
    target_link_libraries(QuaZip::QuaZip INTERFACE ZLIB::ZLIB wsock32 ws2_32)
endif()
