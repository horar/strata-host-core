#
# libzmq
#

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/libzmq" "${EXTERN_INSTALL_DIR_PATH}/libzmq")
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
        )
    endif()
else()
    if(WIN32)
        # TODO: RS: File output build dependency for ExternalProject_Add in CMake
        # https://jira.onsemi.com/browse/CS-1442
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            file(COPY "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/bin/libzmqd${CMAKE_SHARED_LIBRARY_SUFFIX}"
                DESTINATION "${CMAKE_BINARY_DIR}/bin")
        else()
            file(COPY "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/bin/libzmq${CMAKE_SHARED_LIBRARY_SUFFIX}"
                DESTINATION "${CMAKE_BINARY_DIR}/bin")
        endif()
    endif()
endif()

if(WIN32)
    add_library(zeromq::libzmq SHARED IMPORTED GLOBAL)
elseif(APPLE)
    # TODO: libzmq is shared between DevStudio and Strata. Therefore, this should be dynamic.
    # - During devolopment runtime the dynamic lib should be moved along with bin directory
    # - Proper handling for RPATH with offline & online MacOS installer.
    # https://jira.onsemi.com/browse/CS-1460
    add_library(zeromq::libzmq STATIC IMPORTED GLOBAL)
endif()

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
            IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/libzmq-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zmq${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
endif()
add_dependencies(zeromq::libzmq DEPENDS libzmq)
