include(ExternalProject)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/3rd_party/include)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/3rd_party/lib)

# root of all 3rd party project (git submodules)
set(SOURCE_DIR_EXTERN ${CMAKE_SOURCE_DIR}/../extern)

#
# spdlog
#
ExternalProject_Add(libspdlog
    INSTALL_DIR ${CMAKE_BINARY_DIR}/3rd_party
    SOURCE_DIR ${SOURCE_DIR_EXTERN}/spdlog

    CMAKE_ARGS ${CMAKE_ARGS}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DSPDLOG_BUILD_BENCH=off
        -DSPDLOG_BUILD_EXAMPLES=off
        -DSPDLOG_BUILD_TESTS=off
)

add_library(spdlog::spdlog INTERFACE IMPORTED GLOBAL)
set_target_properties(spdlog::spdlog PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
)
add_dependencies(spdlog::spdlog DEPENDS libspdlog)


#
# pdf.js
#
# [LC] helper sub-project to download/patch/build PDF.js component for SGPdfViewer component
#
if (APPLE)
    option(EXTERN_PDFJS "Build PDF.js library" OFF)
    add_feature_info(EXTERN_PDFJS EXTERN_PDFJS "Build PDF.js library")

    if(EXTERN_PDFJS)
        set(PDFJS_TAG v2.1.266)

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
ExternalProject_Add(libgtest
    INSTALL_DIR ${CMAKE_BINARY_DIR}/3rd_party
    SOURCE_DIR ${SOURCE_DIR_EXTERN}/googletest

    CMAKE_ARGS ${CMAKE_ARGS}
        -Dgtest_force_shared_crt=YES
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
)

add_library(gtest::gtest STATIC IMPORTED GLOBAL)
set_target_properties(gtest::gtest PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX}"
    IMPORTED_LOCATION_DEBUG  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtestd${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_dependencies(gtest::gtest DEPENDS libgtest)


add_library(gtest::gmock STATIC IMPORTED GLOBAL)
set_target_properties(gtest::gmock PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock${CMAKE_STATIC_LIBRARY_SUFFIX}"
    IMPORTED_LOCATION_DEBUG  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmockd${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_dependencies(gtest::gmock DEPENDS libgtest)


#
# couchbase-lite-core
#
if(NOT WIN32)
    ExternalProject_Add(${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore
        INSTALL_DIR ${CMAKE_BINARY_DIR}/3rd_party
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-core
        #GIT_REPOSITORY https://github.com/couchbase/couchbase-lite-core.git
        #GIT_TAG 513281b8
        #GIT_PROGRESS ${CMAKE_VERBOSE_MAKEFILE}

        PATCH_COMMAND cd vendor/mbedtls && git reset --hard
        COMMAND git apply -v ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-core_vendor_mbedtls_fix.patch

        CMAKE_ARGS ${CMAKE_ARGS}
            -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DENABLE_TESTING=off
            -DENABLE_PROGRAMS=off

        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different vendor/fleece/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different vendor/BLIP-Cpp/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different vendor/sqlite3-unicodesn/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different REST/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different REST/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreREST_Static${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
    )
else()
    ExternalProject_Add(${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore
        INSTALL_DIR ${CMAKE_BINARY_DIR}/3rd_party
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-core
        #GIT_REPOSITORY https://github.com/couchbase/couchbase-lite-core.git
        #GIT_TAG 513281b8
        #GIT_PROGRESS ${CMAKE_VERBOSE_MAKEFILE}

        CMAKE_ARGS ${CMAKE_ARGS}
            -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DENABLE_TESTING=off
            -DENABLE_PROGRAMS=off

        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different vendor/fleece/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different vendor/BLIP-Cpp/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different vendor/BLIP-Cpp/vendor/zlib/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic$<$<CONFIG:Debug>:d>${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/
        COMMAND ${CMAKE_COMMAND} -E copy_if_different vendor/sqlite3-unicodesn/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different vendor/mbedtls/library/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different REST/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
        COMMAND ${CMAKE_COMMAND} -E copy_if_different REST/${CMAKE_CFG_INTDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreREST_Static${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
    )
endif()

add_library(cblitecore::LiteCore STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::LiteCore PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::LiteCore DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)

add_library(cblitecore::Fleece STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::Fleece PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::Fleece DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)

#add_library(cblitecore::FleeceBase STATIC IMPORTED GLOBAL)
#set_target_properties(cblitecore::FleeceBase PROPERTIES
#    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
#    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceBase${CMAKE_STATIC_LIBRARY_SUFFIX}"
#)
#add_dependencies(cblitecore::FleeceBase DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)

add_library(cblitecore::CivetWeb STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::CivetWeb PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::CivetWeb DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)

add_library(cblitecore::LiteCoreRest STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::LiteCoreRest PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreREST_Static${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::LiteCoreRest DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)

add_library(cblitecore::BLIP STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::BLIP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::BLIP DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)

add_library(cblitecore::support STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::support PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::support DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)

add_library(cblitecore::SQLite3_unicode STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::SQLite3_unicode PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
    IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::SQLite3_unicode DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)
if(WIN32)
    add_library(cblitecore::zlib STATIC IMPORTED GLOBAL)
    set_target_properties(cblitecore::zlib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
        IMPORTED_LOCATION       "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
        #IMPORTED_LOCATION_DEBUG "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstaticd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(cblitecore::zlib DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)

    add_library(cblitecore::mbedtls STATIC IMPORTED GLOBAL)
    set_target_properties(cblitecore::mbedtls PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_BINARY_DIR}/3rd_party/include"
        IMPORTED_LOCATION  "${CMAKE_BINARY_DIR}/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(cblitecore::mbedtls DEPENDS ${CMAKE_STATIC_LIBRARY_PREFIX}cblitecore)
endif()


