#
# libzmq
#

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/libzmq" "${EXTERN_INSTALL_DIR_PATH}/libzmq")

function(ReadLibzmqSoVersion)
    file(READ "${SOURCE_DIR_EXTERN}/libzmq/CMakeLists.txt" LIBZMQ_CMAKELIST)
    string(REGEX MATCH "SOVERSION \"([0-9\\.]+)\"" _ ${LIBZMQ_CMAKELIST})
    if( DEFINED CMAKE_MATCH_1 AND NOT CMAKE_MATCH_1 STREQUAL "" )
        message(STATUS "Detected LIBZMQ_SOVERSION: ${CMAKE_MATCH_1}")
    else()
        message( FATAL_ERROR "Unable to detect LIBZMQ_SOVERSION, cmake will exit")
    endif()
    set(LIBZMQ_SOVERSION ${CMAKE_MATCH_1} PARENT_SCOPE)
    mark_as_advanced(LIBZMQ_SOVERSION)
endfunction()

function(InstallPkgConfig)
    # Use Homebrew to search for pkg-config, install it if not found
    find_program(BREW_PROGRAM brew)
    mark_as_advanced(BREW_PROGRAM)

    if(BREW_PROGRAM)
        find_program(SED_PROGRAM sed)
        mark_as_advanced(SED_PROGRAM)

        find_program(BASH_PROGRAM bash)
        mark_as_advanced(BASH_PROGRAM)

        if(BASH_PROGRAM AND SED_PROGRAM)
            execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} config | ${SED_PROGRAM} -n -E 's/^HOMEBREW_PREFIX: (.+)$$/\\1/p'" OUTPUT_VARIABLE HOMEBREW_PREFIX)
            string(STRIP "${HOMEBREW_PREFIX}" HOMEBREW_PREFIX)
            unset(PKG_CONFIG_OUTPUT)
            execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} ls --versions pkg-config" OUTPUT_VARIABLE PKG_CONFIG_OUTPUT)
            if("${PKG_CONFIG_OUTPUT}" STREQUAL "")
                # Result is empty -- pkg-config not found
                # Install pkg-config
                execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} install pkg-config")
                message(STATUS "Installed pkg-config through Homebrew.")
            else()
                message(STATUS "Found pkg-config installation through Homebrew.")
            endif()
        endif()
    else()
        message(FATAL_ERROR "Homebrew must be installed to continue compilation.")
    endif()
endfunction()

if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib)

    if(WIN32)
        ExternalProject_Add(libzmq
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/libzmq
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DCMAKE_PDB_OUTPUT_DIRECTORY=<INSTALL_DIR>/bin
                -DWITH_PERF_TOOL=OFF
                -DZMQ_BUILD_TESTS=OFF
                -DENABLE_CPACK=OFF

            PATCH_COMMAND ${GIT_EXECUTABLE} reset --hard && ${GIT_EXECUTABLE} apply --verbose --ignore-space-change --ignore-whitespace ${CMAKE_CURRENT_SOURCE_DIR}/patches/libzmq/jom-build-support.patch
            && ${GIT_EXECUTABLE} apply --verbose --ignore-space-change --ignore-whitespace ${CMAKE_CURRENT_SOURCE_DIR}/patches/libzmq/remove-library-name-postfix.patch

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <INSTALL_DIR>/bin/libzmq$<$<CONFIG:DEBUG>:d>${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin
        )
    else()
        ReadLibzmqSoVersion()
        InstallPkgConfig()
        ExternalProject_Add(libzmq
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/libzmq
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DCMAKE_MACOSX_RPATH=1
                -DWITH_PERF_TOOL=OFF
                -DZMQ_BUILD_TESTS=OFF
                -DENABLE_CPACK=OFF

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}zmq${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_BINARY_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}zmq${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}zmq.${LIBZMQ_SOVERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}
        )
    endif()
else()
    # TODO: RS: File output build dependency for ExternalProject_Add in CMake
    # https://jira.onsemi.com/browse/CS-1442
    if(WIN32)
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/bin/libzmqd${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin
            )
        else()
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/bin/libzmq${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin
            )
        endif()
    else()
        # re-run the detection in case user keeps swapping branches with different libzmq libraries
        ReadLibzmqSoVersion()
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}zmq${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_BINARY_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}zmq${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}zmq.${LIBZMQ_SOVERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}
        )
    endif()
endif()

add_library(zeromq::libzmq SHARED IMPORTED GLOBAL)

if(WIN32)
    set_target_properties(zeromq::libzmq PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/include"
            IMPORTED_LOCATION "${CMAKE_BINARY_DIR}/bin/libzmq${CMAKE_SHARED_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${CMAKE_BINARY_DIR}/bin/libzmqd${CMAKE_SHARED_LIBRARY_SUFFIX}"
            IMPORTED_IMPLIB "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib/libzmq${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_IMPLIB_DEBUG "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib/libzmqd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
else()
    set_target_properties(zeromq::libzmq PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/include"
            IMPORTED_LOCATION "${CMAKE_BINARY_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}zmq${CMAKE_SHARED_LIBRARY_SUFFIX}"
    )
endif()
add_dependencies(zeromq::libzmq DEPENDS libzmq)
