macro(get_git_hash GIT_REPO_PATH)
    if(${ARGC} GREATER 1)
        set(REF ${ARGV1})
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
endmacro()