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
