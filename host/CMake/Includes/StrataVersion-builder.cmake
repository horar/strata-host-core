#create a pretty commit id using git
#uses 'git describe --tags', so tags are required in the repo
#create a tag with 'git tag <name>' and 'git push --tags'

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

    if(${GIT_COMMIT_ID_VLIST_COUNT} STREQUAL "2")
        # no. patch
        set(VERSION_PATCH "0")
        # SHA1 string + git 'dirty' flag
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+(.*)" "\\1" VERSION_SHA1 "${GIT_COMMIT_ID}")
    else()
        # no. patch
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" VERSION_PATCH "${GIT_COMMIT_ID}")
        # SHA1 string + git 'dirty' flag
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+(.*)" "\\1" VERSION_SHA1 "${GIT_COMMIT_ID}")
    endif()

    set(PROJECT_VERSION "v${GIT_COMMIT_ID}")
    message(STATUS "Strata version: ${PROJECT_VERSION} [git]")
else()
    message(STATUS "Strata version: ${PROJECT_VERSION} [cmake]")
endif()

message(STATUS "Processing Strata vesion file...")
file(READ ${INPUT_DIR}/StrataVersion.cpp.in cpp_temporary)
string(CONFIGURE "${cpp_temporary}" cpp_updated @ONLY)
file(WRITE ${OUTPUT_DIR}/StrataVersion.cpp.tmp "${cpp_updated}")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${OUTPUT_DIR}/StrataVersion.cpp.tmp ${OUTPUT_DIR}/StrataVersion.cpp
)
