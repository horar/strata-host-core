include(ExternalProject)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/3rd_party/include)

#
# spdlog
#
ExternalProject_Add(libspdlog
    INSTALL_DIR ${CMAKE_BINARY_DIR}/3rd_party
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/spdlog

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
    option(EXTERN_PDFJS "Build PDF.js component" OFF)
    add_feature_info(EXTERN_PDFJS EXTERN_PDFJS "Build PDF.js ")

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
