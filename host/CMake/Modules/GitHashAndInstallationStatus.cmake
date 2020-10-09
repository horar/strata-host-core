macro(get_git_hash_and_installation_status GIT_REPO_PATH LIB_INSTALLATION_PATH)
    if(${ARGC} GREATER 2)
        set(REF ${ARGV2})
    else()
        set(REF "HEAD")
    endif()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short=5 ${REF}
        WORKING_DIRECTORY ${GIT_REPO_PATH}
        OUTPUT_VARIABLE GIT_HASH
        RESULTS_VARIABLE GIT_HASH_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT ${GIT_HASH_RESULT} EQUAL 0)
        message(FATAL_ERROR "Failed to get git hash for ${GIT_REPO_PATH}. GIT_HASH_RESULT is: ${GIT_HASH_RESULT}")
    endif()

    # checks for header files in a given path
    file(GLOB_RECURSE LIB_INSTALLED ${LIB_INSTALLATION_PATH}-${GIT_HASH}/*.h)
endmacro()