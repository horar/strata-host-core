macro(get_git_hash GIT_REPO_PATH)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short=5 HEAD
        WORKING_DIRECTORY ${GIT_REPO_PATH}
        OUTPUT_VARIABLE GIT_HASH
        RESULTS_VARIABLE GIT_HASH_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endmacro()