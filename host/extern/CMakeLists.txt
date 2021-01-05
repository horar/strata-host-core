option(BUILD_DONT_CLEAN_EXTERNAL "Don't clean external project (Makefile only)" OFF)
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
    set(EXTERN_INSTALL_DIR_PATH ${CMAKE_BINARY_DIR}/${EXTERN_INSTALL_DIR_NAME} CACHE STRING "" FORCE)
    message(STATUS "EXTERN_INSTALL_DIR_PATH is : ${EXTERN_INSTALL_DIR_PATH}")
endif()

# root of all 3rd party project (git submodules)
set(SOURCE_DIR_EXTERN ${CMAKE_SOURCE_DIR}/../extern)

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


#
# pdf.js
#
# [LC] helper sub-project to download/patch/build PDF.js component for SGPdfViewer component
#
if (APPLE)
    option(BUILD_EXTERN_PDFJS "Build PDF.js library" OFF)
    add_feature_info(BUILD_EXTERN_PDFJS BUILD_EXTERN_PDFJS "Build PDF.js library")

    if(BUILD_EXTERN_PDFJS)
        set(PDFJS_TAG v2.3.200)

        find_program(NPM_EXE npm)
        mark_as_advanced(NPM_EXE)
        if(NOT NPM_EXE)
            message(FATAL_ERROR "'npm' program not found; check pdf.js documentation")
        endif()

        find_program(NODE_JS node)
        mark_as_advanced(NODE_JS)
        if(NOT NODE_JS)
            message(FATAL_ERROR "'node.js' program not found; check pdf.js documentation")
        endif()

        find_program(GULP_EXE gulp)
        mark_as_advanced(GULP_EXE)
        if(NOT GULP_EXE)
            message(FATAL_ERROR "'gulp' program not found; check pdf.js documentation")
        endif()

        find_package(Git)
        if(NOT Git_FOUND)
            message(FATAL_ERROR "'git' program not found; can't patch pdf.js!!")
        endif()

        ExternalProject_Add(pdf.js-${PDFJS_TAG}
            EXCLUDE_FROM_ALL ON
            GIT_REPOSITORY https://github.com/mozilla/pdf.js.git
            GIT_TAG ${PDFJS_TAG}
            GIT_PROGRESS ON

            BUILD_IN_SOURCE ON
            BUILD_ALWAYS ON

            PATCH_COMMAND ${GIT_EXECUTABLE} apply --verbose ${CMAKE_CURRENT_SOURCE_DIR}/patches/pdf.js/0001-add-viewer-origins.patch
            COMMAND ${GIT_EXECUTABLE} apply --verbose ${CMAKE_CURRENT_SOURCE_DIR}/patches/pdf.js/0002-remove-default-url-file.patch
            COMMAND ${GIT_EXECUTABLE} apply --verbose ${CMAKE_CURRENT_SOURCE_DIR}/patches/pdf.js/0003-remove-indesired-toolbar-buttons.patch
            COMMAND ${GIT_EXECUTABLE} apply --verbose ${CMAKE_CURRENT_SOURCE_DIR}/patches/pdf.js/0004-remove-keyboard-listeners.patch

            CONFIGURE_COMMAND ${NPM_EXE} install gulp-cli
            COMMAND ${NPM_EXE} install

            BUILD_COMMAND ${GULP_EXE} minified

            INSTALL_COMMAND ${CMAKE_COMMAND} -E echo \'minified\' pdf.js was compiled into: <SOURCE_DIR>/build
            COMMAND ${CMAKE_COMMAND} -E echo Please copy this filder into \'SGPdfViewer\' component.
        )
    endif()
endif()

#
# googletest
#
if(BUILD_TESTING)
    get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/googletest" "${EXTERN_INSTALL_DIR_PATH}/gtest")
    if(NOT LIB_INSTALLED)
        file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/include)
        file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib)
        ExternalProject_Add(gtest
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/googletest
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -Dgtest_force_shared_crt=YES
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        )
    endif()

    add_library(gtest::gtest STATIC IMPORTED GLOBAL)
    set_target_properties(gtest::gtest PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG  "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtestd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )

    add_dependencies(gtest::gtest DEPENDS gtest)

    add_library(gtest::gmock STATIC IMPORTED GLOBAL)
    set_target_properties(gtest::gmock PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG  "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmockd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )

    add_dependencies(gtest::gmock DEPENDS gtest)
endif()

#
# MacOS: Find (or install) OpenSSL through Homebrew
#
if(APPLE)
    # Check cached variables for previously set path
    if(DEFINED SSL_LIB_PATH_MACOS AND NOT SSL_LIB_PATH_MACOS STREQUAL "")
        message(STATUS "OpenSSL libraries directory found in cache: ${SSL_LIB_PATH_MACOS}")

    # Use Homebrew to search for OpenSSL@1.1, install it if not found
    else()
        find_program(BREW_PROGRAM brew)
        mark_as_advanced(BREW_PROGRAM)

        if(BREW_PROGRAM)
            find_program(SED_PROGRAM sed)
            mark_as_advanced(SED_PROGRAM)

            find_program(BASH_PROGRAM bash)
            mark_as_advanced(BASH_PROGRAM)

            if(BASH_PROGRAM AND SED_PROGRAM)
                execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} config | ${SED_PROGRAM} -n -E 's/^HOMEBREW_PREFIX: (.+)$$/\\1/p'" OUTPUT_VARIABLE HOMEBREW_PREFIX)
                string(STRIP "${HOMEBREW_PREFIX}" HOMEBREW_PREFIX)
                unset(OPEN_SSL_OUTPUT)
                execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} ls --versions openssl@1.1" OUTPUT_VARIABLE OPEN_SSL_OUTPUT)
                if("${OPEN_SSL_OUTPUT}" STREQUAL "")
                    # Result is empty -- OpenSSL not found
                    # Install OpenSSL
                    execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} install openssl@1.1")
                    message(STATUS "Installed OpenSSL@1.1 through Homebrew.")
                else()
                    message(STATUS "Found OpenSSL@1.1 installation through Homebrew.")
                endif()
                set(SSL_LIB_PATH_MACOS "${HOMEBREW_PREFIX}/opt/openssl@1.1" CACHE STRING "Directory containing OpenSSL" FORCE)
            endif()
        else()
            message(FATAL_ERROR "Homebrew must be installed to continue compilation.")
        endif()
    endif()
endif()

#
# couchbaselitecpp and couchbase litecore
#
get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/couchbase-lite-cpp" "${EXTERN_INSTALL_DIR_PATH}/cblitecpp")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib)
    if(NOT WIN32)
        ExternalProject_Add(cblitecpp
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-cpp
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DBUILD_EXAMPLES=${BUILD_EXAMPLES}
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DSSL_LIB="$<$<NOT:$<CONFIG:OTA>>:${SSL_LIB_PATH_MACOS}/lib/>libssl.1.1.dylib"
                -DCRYPTO_LIB="$<$<NOT:$<CONFIG:OTA>>:${SSL_LIB_PATH_MACOS}/lib/>libcrypto.1.1.dylib"

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreREST_Static${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib

            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/3rd_party/include/litecore <INSTALL_DIR>/include/litecore
            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/3rd_party/include/fleece <INSTALL_DIR>/include/fleece
        ) 
    else()
        ExternalProject_Add(cblitecpp
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-cpp
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DBUILD_EXAMPLES=${BUILD_EXAMPLES}
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DSSL_LIB="libssl-1_1-x64.dll"
                -DCRYPTO_LIB="libcrypto-1_1-x64.dll"

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreREST_Static${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic$<$<CONFIG:Debug>:d>${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib

            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/3rd_party/include/litecore <INSTALL_DIR>/include/litecore
            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/3rd_party/include/fleece <INSTALL_DIR>/include/fleece
        )
    endif()  
endif()  

add_library(strata::CouchbaseLiteCPP STATIC IMPORTED GLOBAL)
set_target_properties(strata::CouchbaseLiteCPP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}couchbaselitecpp${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(strata::CouchbaseLiteCPP DEPENDS cblitecpp)

add_library(cblitecore::LiteCore STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::LiteCore PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::LiteCore DEPENDS cblitecpp)

add_library(cblitecore::Fleece STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::Fleece PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::Fleece DEPENDS cblitecpp)

add_library(cblitecore::CivetWeb STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::CivetWeb PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::CivetWeb DEPENDS cblitecpp)

add_library(cblitecore::BLIP STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::BLIP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::BLIP DEPENDS cblitecpp)

add_library(cblitecore::support STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::support PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cblitecore::SQLite3_unicode STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::SQLite3_unicode PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(cblitecore::SQLite3_unicode DEPENDS cblitecpp)

if(WIN32)
    add_library(cblitecore::zlib STATIC IMPORTED GLOBAL)
    set_target_properties(cblitecore::zlib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
        IMPORTED_LOCATION       "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstaticd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(cblitecore::zlib DEPENDS cblitecpp)

    add_library(cblitecore::mbedtls STATIC IMPORTED GLOBAL)
    set_target_properties(cblitecore::mbedtls PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(cblitecore::mbedtls DEPENDS cblitecpp)
endif()

target_link_libraries(strata::CouchbaseLiteCPP
    INTERFACE
        cblitecore::LiteCore
        cblitecore::Fleece
        cblitecore::CivetWeb
        cblitecore::BLIP
        cblitecore::SQLite3_unicode
        cblitecore::support
)
if(WIN32)
    target_link_libraries(strata::CouchbaseLiteCPP
        INTERFACE
            cblitecore::zlib
            cblitecore::mbedtls
    )
else()
    target_link_libraries(strata::CouchbaseLiteCPP
        INTERFACE
            z
    )
endif()

if(APPLE)
    find_library(IOKIT_LIB IOKit REQUIRED)
    if (NOT IOKIT_LIB)
        message(FATAL_ERROR "IOKit framework not found")
    endif()
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()

    target_link_libraries(strata::CouchbaseLiteCPP INTERFACE
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
    )
endif()

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

set(QWT_VERSION 6.1.4)
file(GLOB_RECURSE LIB_INSTALLED ${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/*.h)
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}/lib)
    ExternalProject_Add(qwt
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/qwt-${QWT_VERSION}
        URL https://sourceforge.net/projects/qwt/files/qwt/${QWT_VERSION}/qwt-${QWT_VERSION}.zip
        URL_HASH MD5=94cba1069f972706e676ea816582e5ce
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

#
# QtMqtt
#

# to get Qt version for git checkout command
find_package(Qt5 COMPONENTS Core)
get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/qtmqtt" "${EXTERN_INSTALL_DIR_PATH}/qtmqtt" "${Qt5Core_VERSION_STRING}")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib)
    if(NOT WIN32)
        ExternalProject_Add(mqtt
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/qtmqtt
            EXCLUDE_FROM_ALL ON
            CONFIGURE_COMMAND ${QT_QMAKE_EXECUTABLE} "CONFIG+=debug_and_release build_all" ${SOURCE_DIR_EXTERN}/qtmqtt/qtmqtt.pro
            COMMAND ${GIT_EXECUTABLE} --git-dir=${SOURCE_DIR_EXTERN}/qtmqtt/.git checkout ${Qt5Core_VERSION_STRING}
            BUILD_COMMAND make # needed to do the build before copying the lib to 3p dir
            INSTALL_COMMAND

            COMMAND ${CMAKE_INSTALL_NAME_TOOL} -id <INSTALL_DIR>/lib/QtMqtt <BINARY_DIR>/lib/QtMqtt.framework/Versions/5/QtMqtt
            COMMAND ${CMAKE_INSTALL_NAME_TOOL} -id <INSTALL_DIR>/lib/QtMqtt_debug <BINARY_DIR>/lib/QtMqtt.framework/Versions/5/QtMqtt_debug
            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/lib/QtMqtt.framework/Headers <INSTALL_DIR>/include/QtMqtt
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/lib/QtMqtt.framework/Versions/5/QtMqtt <BINARY_DIR>/lib/QtMqtt.framework/Versions/5/QtMqtt_debug <INSTALL_DIR>/lib
        )
    else()

        # Search for perl path to add it to the path
        set(PERL_PATH  "")
        include(FindPerl)
        if( NOT PERL_FOUND )
            set(EXPECTED_PATH_TO_PERL "$ENV{PROGRAMFILES}\\Git\\usr\\bin")
            find_program(PERL_EXECUTABLE
                NAMES perl
                PATHS ${EXPECTED_PATH_TO_PERL}
            )
            if(PERL_EXECUTABLE)
                include(FindPerl)
            endif()
        endif()

        if(PERL_FOUND)
            get_filename_component(PERL_PATH "${PERL_EXECUTABLE}" PATH)

            # Create a cmd command to append Perl's path to the environment PATH
            string(REPLACE ";" "$<SEMICOLON>" MODIFIED_PATH "$ENV{PATH}")
            separate_arguments(APPEND_PERL_TO_PATH WINDOWS_COMMAND "SET PATH=${MODIFIED_PATH}$<SEMICOLON>${PERL_PATH}")
        else()
            message(FATAL_ERROR "Perl NOT found. Please make sure that Perl is installed and added to the path.")
        endif()

        ExternalProject_Add(mqtt
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/qtmqtt
            EXCLUDE_FROM_ALL ON
            CONFIGURE_COMMAND ${QT_QMAKE_EXECUTABLE} ${SOURCE_DIR_EXTERN}/qtmqtt/qtmqtt.pro -spec win32-msvc
            COMMAND ${GIT_EXECUTABLE} --git-dir=${SOURCE_DIR_EXTERN}/qtmqtt/.git checkout ${Qt5Core_VERSION_STRING}
            COMMAND ${APPEND_PERL_TO_PATH}
            BUILD_COMMAND
            INSTALL_COMMAND

            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/src/mqtt/ <INSTALL_DIR>/include/QtMqtt
            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/bin <INSTALL_DIR>/bin
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/bin/Qt5Mqtt.dll <BINARY_DIR>/bin/Qt5Mqttd.dll ${CMAKE_BINARY_DIR}/bin
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/lib/Qt5Mqtt.lib <BINARY_DIR>/lib/Qt5Mqttd.lib <BINARY_DIR>/lib/Qt5Mqttd.pdb <INSTALL_DIR>/lib
        )
    endif()
else()
    if(WIN32)
        file(COPY ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/bin/Qt5Mqttd.dll
        ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/bin/Qt5Mqtt.dll
        DESTINATION ${CMAKE_BINARY_DIR}/bin)
    endif()
endif()

add_library(mqtt::mqtt STATIC IMPORTED GLOBAL)

if(NOT WIN32)
    set_target_properties(mqtt::mqtt PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/include"
        IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib/QtMqtt"
        IMPORTED_LOCATION_DEBUG "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib/QtMqtt_debug"
    )
else()
    set_target_properties(mqtt::mqtt PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/include"
        IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib/Qt5Mqtt.lib"
        IMPORTED_LOCATION_DEBUG "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib/Qt5Mqttd.lib"
    )
endif()

add_dependencies(mqtt::mqtt DEPENDS mqtt)

#
# Couchbase-Lite-C (official API)
#
get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/couchbase-lite-C" "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib)
    if(NOT WIN32)
        ExternalProject_Add(cb-lite-c
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-C

            # Must add dependency to avoid conflict with CouchbaseLiteCPP build
            DEPENDS strata::CouchbaseLiteCPP
            EXCLUDE_FROM_ALL ON
            # Apply patches
            PATCH_COMMAND cd ${SOURCE_DIR_EXTERN}/.. && git submodule --quiet update --force --recursive extern/couchbase-lite-C
            COMMAND cd ${SOURCE_DIR_EXTERN}/couchbase-lite-C && git apply -v ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-c/cb-lite-c.patch ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-c/cb-lite-core.patch

            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install

            # Couchbase-Lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # LiteCore
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # BLIP
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/Networking/BLIP/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # Fleece
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/fleece/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # MbedTLS
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls-O${CMAKE_STATIC_LIBRARY_SUFFIX}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509-O${CMAKE_STATIC_LIBRARY_SUFFIX}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/crypto/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # SQLite3_Unicode
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/sqlite3-unicodesn/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # CouchbaseSqlite3
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/include/cbl++ <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/include/cbl <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/src <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/vendor/couchbase-lite-core/vendor/fleece/API/fleece <INSTALL_DIR>/include/fleece
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/vendor/couchbase-lite-core/vendor/fleece/Fleece/Support <INSTALL_DIR>/include/fleece
        )
    else()
        ExternalProject_Add(cb-lite-c
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-C

            # Must add dependency to avoid conflict with CouchbaseLiteCPP build
            DEPENDS strata::CouchbaseLiteCPP
            EXCLUDE_FROM_ALL ON
            # Apply patches
            PATCH_COMMAND cd ${SOURCE_DIR_EXTERN}/.. && git submodule --quiet update --force --recursive extern/couchbase-lite-C
            COMMAND cd ${SOURCE_DIR_EXTERN}/couchbase-lite-C && git apply -v ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-c/cb-lite-c.patch ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-c/cb-lite-core.patch

            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install

            # Couchbase-Lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # LiteCore
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # BLIP
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/Networking/BLIP/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # Fleece
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/fleece/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # MbedTLS
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls-O${CMAKE_STATIC_LIBRARY_SUFFIX}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509-O${CMAKE_STATIC_LIBRARY_SUFFIX}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/crypto/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # SQLite3_Unicode
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/sqlite3-unicodesn/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # CouchbaseSqlite3
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # zlib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/Networking/BLIP/vendor/zlib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic$<$<CONFIG:Debug>:d>${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/include/cbl++ <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/include/cbl <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/src <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/vendor/couchbase-lite-core/vendor/fleece/API/fleece <INSTALL_DIR>/include/fleece
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/vendor/couchbase-lite-core/vendor/fleece/Fleece/Support <INSTALL_DIR>/include/fleece
        )
    endif()
endif()

add_library(strata::Couchbase-Lite-C STATIC IMPORTED GLOBAL)
set_target_properties(strata::Couchbase-Lite-C PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(strata::Couchbase-Lite-C DEPENDS cb-lite-c)

add_library(cb-lite-c::LiteCore STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::LiteCore PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cb-lite-c::LiteCore DEPENDS strata::Couchbase-Lite-C)

add_library(cb-lite-c::CouchbaseSqlite3 STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::CouchbaseSqlite3 PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cb-lite-c::CouchbaseSqlite3 DEPENDS strata::Couchbase-Lite-C)

add_library(cb-lite-c::Fleece STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::Fleece PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cb-lite-c::Fleece DEPENDS strata::Couchbase-Lite-C)

add_library(cb-lite-c::BLIP STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::BLIP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::SQLite3_unicode STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::SQLite3_unicode PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::mbedcrypto STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::mbedcrypto PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::mbedtls STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::mbedtls PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::mbedx509 STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::mbedx509 PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::LiteCoreWebSocket STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::LiteCoreWebSocket PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::sockpp STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::sockpp PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
)

if(WIN32)
    add_library(zlib STATIC IMPORTED GLOBAL)
    set_target_properties(zlib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(zlib DEPENDS strata::Couchbase-Lite-C)
endif()

if(APPLE)
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    target_link_libraries(cb-lite-c::LiteCore INTERFACE "-framework Security")
endif()

target_link_libraries(strata::Couchbase-Lite-C
    INTERFACE
        cb-lite-c::LiteCore
        cb-lite-c::Fleece
        cb-lite-c::BLIP
        cb-lite-c::SQLite3_unicode
        cb-lite-c::mbedcrypto
        cb-lite-c::mbedtls
        cb-lite-c::mbedx509
        cb-lite-c::LiteCoreWebSocket
        cb-lite-c::CouchbaseSqlite3
)

if(APPLE)
    target_link_libraries(strata::Couchbase-Lite-C INTERFACE z ${FOUNDATION_LIB})
endif()

if(WIN32)
    target_link_libraries(strata::Couchbase-Lite-C INTERFACE zlib wsock32 ws2_32)
endif()


#
# libzmq
#
get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/libzmq" "${EXTERN_INSTALL_DIR_PATH}/libzmq")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib)

    if(WIN32)
        ExternalProject_Add(libzmq
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/libzmq
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

            PATCH_COMMAND ${GIT_EXECUTABLE} apply --verbose --ignore-space-change --ignore-whitespace ${CMAKE_CURRENT_SOURCE_DIR}/patches/libzmq/libzmq-windows-v4.2.2.patch

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <INSTALL_DIR>/bin/libzmq-mt$<$<NOT:$<CONFIG:RELEASE>>:-gd>-4_2_2${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin
        )
    else()
        ExternalProject_Add(libzmq
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/libzmq
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        )
    endif()
endif()

add_library(zeromq::libzmq SHARED IMPORTED GLOBAL)

if(WIN32)
    set_target_properties(zeromq::libzmq PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/include"
            IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/bin/libzmq-mt-gd-4_2_2${CMAKE_SHARED_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELEASE "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/bin/libzmq-mt-4_2_2${CMAKE_SHARED_LIBRARY_SUFFIX}"
            IMPORTED_IMPLIB "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib/libzmq-mt-gd-4_2_2${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_IMPLIB_RELEASE "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib/libzmq-mt-4_2_2${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
else()
    set_target_properties(zeromq::libzmq PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/include"
            IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}zmq${CMAKE_SHARED_LIBRARY_SUFFIX}"
    )
endif()
add_dependencies(zeromq::libzmq DEPENDS libzmq)
# TODO: cppzmq (c++ headers only zmq wrapper) & zhelper.hpp are still referenced from our source code
# https://jira.onsemi.com/browse/CS-1416