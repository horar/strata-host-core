##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# monaco-editor
# This will download and install a third party IDE Editor resource into the extern build folder
# Because this repo does not have source code in Git and is already compiled, the resource can
# simply be unarchived and the min/vs, min-maps/vs, and the monaco.d.ts can be "installed" to the build folder
#
set(MONACO_TAG 0.21.3)

file(COPY ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/qtQuick.js
    ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/editor.html
    ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/qtQuickTypes.js
    DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../components/monaco/qml/tech/strata/monaco/minified/
)

file(COPY ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/model/qtItemModel.js
    ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/model/qtQuickModel.js
    DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../components/monaco/qml/tech/strata/monaco/minified/model/
)

file(COPY ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/utils/helper.js
     ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/utils/search.js
     ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/utils/suggestions.js
    DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../components/monaco/qml/tech/strata/monaco/minified/utils/
)

execute_process(
    COMMAND ${GIT_EXECUTABLE} apply --verbose --ignore-space-change --ignore-whitespace extern/patches/monaco/adjust-uuid-search.patch
    OUTPUT_VARIABLE MONACO_GIT_APPLY_STDOUT
    ERROR_VARIABLE MONACO_GIT_APPLY_STDERR
    RESULT_VARIABLE MONACO_GIT_APPLY_RESULT_CODE
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

if( NOT MONACO_GIT_APPLY_STDOUT STREQUAL "" )
    message(STATUS "${MONACO_GIT_APPLY_STDOUT}")
endif()

if( ${MONACO_GIT_APPLY_RESULT_CODE} EQUAL 0 )
    if( NOT MONACO_GIT_APPLY_STDERR STREQUAL "" )
        # git uses stderr for some reason for debug messages so they all end here, they can be diferentiated using error code
        message( STATUS "${MONACO_GIT_APPLY_STDERR}")
    endif()
else()
    message( FATAL_ERROR "Git apply failed with error code (${MONACO_GIT_APPLY_RESULT_CODE}) and error: ${MONACO_GIT_APPLY_STDERR}")
endif()

ExternalProject_Add(monaco-editor-${MONACO_TAG}
    SOURCE_DIR ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/package
    INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/monaco-editor-${MONACO_TAG}
    DOWNLOAD_DIR ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/tar
    BUILD_ALWAYS ON
    URL https://registry.npmjs.org/monaco-editor/-/monaco-editor-${MONACO_TAG}.tgz
    URL_HASH SHA1=3381b66614b64d1c5e3b77dd5564ad496d1b4e5d
    CONFIGURE_COMMAND ""
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/monaco.d.ts ${CMAKE_CURRENT_SOURCE_DIR}/../components/monaco/qml/tech/strata/monaco/minified/monaco.d.ts
    COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/min/vs ${CMAKE_CURRENT_SOURCE_DIR}/../components/monaco/qml/tech/strata/monaco/minified/min/vs
    COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/min-maps/vs ${CMAKE_CURRENT_SOURCE_DIR}/../components/monaco/qml/tech/strata/monaco/minified/min-maps/vs
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)
