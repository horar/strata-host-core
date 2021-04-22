get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/libevent" "${EXTERN_INSTALL_DIR_PATH}/libevent")

file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/include)
file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/lib)
ExternalProject_Add(libevent
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/libevent
        EXCLUDE_FROM_ALL ON
        CMAKE_ARGS "${CMAKE_ARGS}"
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DEVENT__DISABLE_OPENSSL=ON
            -DEVENT__BUILD_SHARED_LIBRARIES=ON
            -DEVENT__DISABLE_BENCHMARK=ON
            -DCMAKE_MACOSX_RPATH=1

        COPY_DYNAMIC_LIB_TO_BIN
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install

)
ExternalProject_Add_Step(libevent COPY_DYNAMIC_LIB_TO_BIN
        COMMENT "Copy libevent dynamic lib in case does not exist in the bin directory"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}event_core.2.1.8${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_BINARY_DIR}/bin
        ALWAYS ON
        DEPENDEES install build
)

add_library(libevent::libevent SHARED IMPORTED GLOBAL)

set_target_properties(libevent::libevent PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/include"
        IMPORTED_LOCATION "${CMAKE_BINARY_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}event_core.2.1.8${CMAKE_SHARED_LIBRARY_SUFFIX}"
)

add_dependencies(libevent::libevent DEPENDS libevent)
