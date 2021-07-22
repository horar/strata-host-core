#
# QWT
#

find_package(Git)
if(NOT Git_FOUND)
    message(FATAL_ERROR "'git' program not found; can't patch QWT!!")
endif()

if(NOT DEFINED QT_QMAKE_EXECUTABLE OR QT_QMAKE_EXECUTABLE STREQUAL "")
    find_program(QT_QMAKE_EXECUTABLE "qmake"  PATHS ${CMAKE_PREFIX_PATH})
    if(QT_QMAKE_EXECUTABLE MATCHES "NOTFOUND$") # regex to match 'QT_QMAKE_EXECUTABLE-NOTFOUND'
        unset(QT_QMAKE_EXECUTABLE CACHE) # reset QT_QMAKE_EXECUTABLE so it is not cached as 'QT_QMAKE_EXECUTABLE-NOTFOUND'
        message(FATAL_ERROR "QT_QMAKE_EXECUTABLE not defined & not found. Define with -DQT_QMAKE_EXECUTABLE=<QT directory>/5.XX.X/clang_64/bin/qmake" )
    endif()
    message(STATUS "Found qmake: ${QT_QMAKE_EXECUTABLE}")
endif()

set(QWT_VERSION 6.1.6)
file(GLOB_RECURSE LIB_INSTALLED ${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/*.h)
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/lib)
    ExternalProject_Add(qwt
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}
        URL https://sourceforge.net/projects/qwt/files/qwt/${QWT_VERSION}/qwt-${QWT_VERSION}.zip
        URL_HASH MD5=5f59c0843484afb1462d21444227d6f6
        EXCLUDE_FROM_ALL ON
        DOWNLOAD_DIR ${SOURCE_DIR_EXTERN}
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/qwt
        PATCH_COMMAND git apply --verbose --ignore-whitespace ${CMAKE_CURRENT_SOURCE_DIR}/patches/qwt/qwtconfig.patch
        CONFIGURE_COMMAND ${QT_QMAKE_EXECUTABLE} QWT_INSTALL_PREFIX=<INSTALL_DIR> ${SOURCE_DIR_EXTERN}/qwt/qwt.pro
    )
endif()

add_library(qwt::qwt STATIC IMPORTED GLOBAL)
if(NOT WIN32)
    set_target_properties(qwt::qwt PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/include"
        IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}qwt${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
else()
    set_target_properties(qwt::qwt PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/include"
        IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}qwt${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}qwtd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
endif()
add_dependencies(qwt::qwt DEPENDS qwt)
