##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

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
