##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# qt-solutions
#

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/qt-solutions" "${EXTERN_INSTALL_DIR_PATH}/qtsol")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qtsol-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qtsol-${GIT_HASH}/lib)
    ExternalProject_Add(qt-solutions
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/qtsol-${GIT_HASH}
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/qt-solutions
        EXCLUDE_FROM_ALL ON
        CMAKE_ARGS "${CMAKE_ARGS}"
            -DQt5_DIR=${Qt5_DIR}
            -DVERSION_QT5=${VERSION_QT5}
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

        PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/extern/patches/qt-solutions/CMakeLists_qt-solutions.cmake.in
            <SOURCE_DIR>/CMakeLists.txt

        # Note: ninja-1.8.2 & cmake-3.10.2 failed in find/install this dependency wo next 2 lines :(
        BUILD_BYPRODUCTS ${EXTERN_INSTALL_DIR_PATH}/qtsol-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}qtservice${CMAKE_STATIC_LIBRARY_SUFFIX}
    )
endif()

add_library(qt-solutions::qtservice STATIC IMPORTED GLOBAL)
set_target_properties(qt-solutions::qtservice PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/qtsol-${GIT_HASH}/include"
    IMPORTED_LOCATION ${EXTERN_INSTALL_DIR_PATH}/qtsol-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}qtservice${CMAKE_STATIC_LIBRARY_SUFFIX}
)
add_dependencies(qt-solutions::qtservice DEPENDS qt-solutions)
