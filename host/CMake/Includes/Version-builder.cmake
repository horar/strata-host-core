if(IS_DIRECTORY ${GIT_ROOT_DIR}/.git)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --dirty --match "v*"
        WORKING_DIRECTORY ${GIT_ROOT_DIR}
        RESULT_VARIABLE res_var
        OUTPUT_VARIABLE GIT_COM_ID
    )
    if(NOT ${res_var} EQUAL 0)
        set(GIT_COMMIT_ID "?.?.?-unknown")
        message(WARNING "Git failed (not a repo, or no tags). Build will not contain git revision info.")
    endif()
    string(REGEX REPLACE "\n$" "" GIT_COMMIT_ID ${GIT_COM_ID})
    string(REGEX REPLACE "^v" "" GIT_COMMIT_ID ${GIT_COMMIT_ID})

    # check number of digits in version string
    string(REPLACE "." ";" GIT_COMMIT_ID_VLIST ${GIT_COMMIT_ID})
    list(LENGTH GIT_COMMIT_ID_VLIST GIT_COMMIT_ID_VLIST_COUNT)

    # no.: major
    string(REGEX REPLACE "^([0-9]+)\\..*" "\\1" VERSION_MAJOR "${GIT_COMMIT_ID}")
    # no.: minor
    string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" VERSION_MINOR "${GIT_COMMIT_ID}")

    set(PROJECT_VERSION "v${VERSION_MAJOR}.${VERSION_MINOR}")

    if(${GIT_COMMIT_ID_VLIST_COUNT} STREQUAL "2")
        # no. patch
        set(VERSION_PATCH "0")
        string(APPEND PROJECT_VERSION ".0")
        # SHA1 string + git 'dirty' flag
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+(.*)" "\\1" VERSION_SHA1 "${GIT_COMMIT_ID}")
        string(APPEND PROJECT_VERSION "${VERSION_SHA1}")
    else()
        # no. patch
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" VERSION_PATCH "${GIT_COMMIT_ID}")
        string(APPEND PROJECT_VERSION ".${VERSION_PATCH}")
        # SHA1 string + git 'dirty' flag
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+(.*)" "\\1" VERSION_SHA1 "${GIT_COMMIT_ID}")
        string(APPEND PROJECT_VERSION "${VERSION_SHA1}")
    endif()

    set(VERSION_TWEAK ${PROJECT_VERSION_TWEAK})

    message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION}")
else()
    message(FATAL_ERROR "Not a git cloned project. Can't create version string from git tag!!")
endif()

message(STATUS "Processing ${PROJECT_NAME} version file...")
file(READ ${INPUT_DIR}/Version.cpp.in versionFile_temporary)
string(CONFIGURE "${versionFile_temporary}" versionFile_updated @ONLY)
file(WRITE ${OUTPUT_DIR}/${PROJECT_NAME}Version.cpp.tmp "${versionFile_updated}")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${OUTPUT_DIR}/${PROJECT_NAME}Version.cpp.tmp ${OUTPUT_DIR}/${PROJECT_NAME}Version.cpp
)

if(APPLE)
    message(STATUS "Processing ${PROJECT_NAME} Info.plist file...")
    file(READ ${INPUT_DIR}/Info.plist.in plistFile_temporary)
    string(CONFIGURE "${plistFile_temporary}" plistFile_updated @ONLY)
    file(WRITE ${OUTPUT_DIR}/${PROJECT_NAME}.plist.tmp "${plistFile_updated}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${OUTPUT_DIR}/${PROJECT_NAME}.plist.tmp ${OUTPUT_DIR}/${PROJECT_NAME}.plist
    )
endif()
