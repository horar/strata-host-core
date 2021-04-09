#
# spdlog
#

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/spdlog" "${EXTERN_INSTALL_DIR_PATH}/spdlog")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/spdlog-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/spdlog-${GIT_HASH}/lib)
    ExternalProject_Add(spdlog
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/spdlog-${GIT_HASH}
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/spdlog
        EXCLUDE_FROM_ALL ON
        CMAKE_ARGS "${CMAKE_ARGS}"
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DSPDLOG_BUILD_SHARED=off
            -DSPDLOG_BUILD_BENCH=off
            -DSPDLOG_BUILD_EXAMPLE=off
            -DSPDLOG_BUILD_TESTS=off
            -DSPDLOG_NO_EXCEPTIONS=on
    )
endif()

add_library(spdlog::spdlog INTERFACE IMPORTED GLOBAL)
set_target_properties(spdlog::spdlog PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/spdlog-${GIT_HASH}/include"
)
add_dependencies(spdlog::spdlog DEPENDS spdlog)
