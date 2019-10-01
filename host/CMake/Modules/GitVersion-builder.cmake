if(IS_DIRECTORY ${GIT_ROOT_DIR}/.git OR NOT USE_GITTAG_VERSION)
    if (USE_GITTAG_VERSION)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --tags --dirty --match "${GITTAG_PREFIX}v*"
            WORKING_DIRECTORY ${GIT_ROOT_DIR}
            RESULT_VARIABLE res_var
            OUTPUT_VARIABLE GIT_COMMIT_ID
        )
    else()
        message(STATUS "Reading version strings from Git tags disabled. Defaulting to 'v0.1.0'...")
        set(GIT_COMMIT_ID "0.1.0\n")
    endif()
    if(NOT ${res_var} EQUAL 0)
        message(STATUS "FAILED to receive Git version (not a repo, or no project tags). Defaulting to zero-version.")
        set(GIT_COMMIT_ID "0.0.0\n")
    endif()
    string(REGEX REPLACE "\n$" "" GIT_COMMIT_ID ${GIT_COMMIT_ID})
    string(REGEX REPLACE "^${GITTAG_PREFIX}v" "" GIT_COMMIT_ID ${GIT_COMMIT_ID})

    # check number of digits in version string
    string(REPLACE "." ";" GIT_COMMIT_ID_VLIST ${GIT_COMMIT_ID})
    list(LENGTH GIT_COMMIT_ID_VLIST GIT_COMMIT_ID_VLIST_COUNT)

    # no.: major
    string(REGEX REPLACE "^([0-9]+)\\..*" "\\1" VERSION_MAJOR "${GIT_COMMIT_ID}")
    # no.: minor
    string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" VERSION_MINOR "${GIT_COMMIT_ID}")

    set(PROJECT_VERSION "v${VERSION_MAJOR}.${VERSION_MINOR}")

    set(VERSION_TWEAK ${PROJECT_VERSION_TWEAK})

    if(${GIT_COMMIT_ID_VLIST_COUNT} STREQUAL "2")
        # no. patch
        set(VERSION_PATCH "0")
        string(APPEND PROJECT_VERSION ".0")
        string(APPEND PROJECT_VERSION ".${VERSION_TWEAK}")
        # SHA1 string + git 'dirty' flag
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+(.*)" "\\1" VERSION_SHA1 "${GIT_COMMIT_ID}")
    else()
        # no. patch
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" VERSION_PATCH "${GIT_COMMIT_ID}")
        string(APPEND PROJECT_VERSION ".${VERSION_PATCH}")
        string(APPEND PROJECT_VERSION ".${VERSION_TWEAK}")
        # SHA1 string + git 'dirty' flag
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+(.*)" "\\1" VERSION_SHA1 "${GIT_COMMIT_ID}")
    endif()
    string(APPEND PROJECT_VERSION "${VERSION_SHA1}")

    message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION}")
else()
    message(FATAL_ERROR "Not a git cloned project. Can't create version string from git tag!!")
endif()

message(STATUS "Processing ${PROJECT_NAME} version file...")
file(READ ${INPUT_DIR}/${INPUT_FILE}.in versionFile_temporary)
string(CONFIGURE "${versionFile_temporary}" versionFile_updated @ONLY)
file(WRITE ${OUTPUT_DIR}/${OUTPUT_FILE}.tmp "${versionFile_updated}")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${OUTPUT_DIR}/${OUTPUT_FILE}.tmp ${OUTPUT_DIR}/${OUTPUT_FILE}
)

if(APPLE AND PROJECT_MACBUNDLE)
    message(STATUS "Processing ${PROJECT_NAME} Info.plist file...")
    file(READ ${INPUT_DIR}/Info.plist.in plistFile_temporary)
    string(CONFIGURE "${plistFile_temporary}" plistFile_updated @ONLY)
    file(WRITE ${OUTPUT_DIR}/${PROJECT_NAME}.plist.tmp "${plistFile_updated}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${OUTPUT_DIR}/${PROJECT_NAME}.plist.tmp ${OUTPUT_DIR}/${PROJECT_NAME}.plist
    )
elseif(WIN32)
    message(STATUS "Processing ${PROJECT_NAME} application RC file...")
    file(READ ${INPUT_DIR}/App.rc.in rcFile_temporary)
    string(CONFIGURE "${rcFile_temporary}" rcFile_updated @ONLY)
    file(WRITE ${OUTPUT_DIR}/${PROJECT_NAME}.rc.tmp "${rcFile_updated}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${OUTPUT_DIR}/${PROJECT_NAME}.rc.tmp ${OUTPUT_DIR}/${PROJECT_NAME}.rc
    )
else()
    message(STATUS "Nothing platform specific to generate on this openrating system.")
endif()