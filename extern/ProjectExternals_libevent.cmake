get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/libevent" "${EXTERN_INSTALL_DIR_PATH}/libevent")

file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/include)
file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/lib)

if(APPLE)
    set(MACOSX_CMAKE_ARGS "-DCMAKE_MACOSX_RPATH=1")
else()
    set(MACOSX_CMAKE_ARGS "")
endif()

ExternalProject_Add(libevent
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/libevent
        EXCLUDE_FROM_ALL ON
        CMAKE_ARGS "${CMAKE_ARGS}"
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DEVENT__DISABLE_OPENSSL=ON
            -DEVENT__BUILD_SHARED_LIBRARIES=ON
            -DEVENT__DISABLE_BENCHMARK=ON
            -DEVENT__DISABLE_SAMPLES=ON
            -DEVENT__DISABLE_TESTS=ON
            ${MACOSX_CMAKE_ARGS}

        COPY_DYNAMIC_LIB_TO_BIN
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
)

if(APPLE)
    set(LIBEVENT_DYNAMIC_LIB_PATH "${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}event_core.2.1.8${CMAKE_SHARED_LIBRARY_SUFFIX}")
elseif(WIN32)
    set(LIBEVENT_DYNAMIC_LIB_PATH ${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}event_core${CMAKE_SHARED_LIBRARY_SUFFIX})
else()
    set(LIBEVENT_DYNAMIC_LIB_PATH "")
endif()

ExternalProject_Add_Step(libevent COPY_DYNAMIC_LIB_TO_BIN
        COMMENT "Copy libevent dynamic library from ${LIBEVENT_DYNAMIC_LIB_PATH} to ${CMAKE_BINARY_DIR}/bin"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LIBEVENT_DYNAMIC_LIB_PATH} ${CMAKE_BINARY_DIR}/bin
        ALWAYS ON
        DEPENDEES install
)

add_library(libevent::libevent SHARED IMPORTED GLOBAL)

if(WIN32)
    set_target_properties(libevent::libevent PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/include"
            IMPORTED_LOCATION "${CMAKE_BINARY_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}event_core${CMAKE_SHARED_LIBRARY_SUFFIX}"
            IMPORTED_IMPLIB "${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/lib/event_core${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
else()
    set_target_properties(libevent::libevent PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/libevent-${GIT_HASH}/include"
            IMPORTED_LOCATION "${CMAKE_BINARY_DIR}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}event_core.2.1.8${CMAKE_SHARED_LIBRARY_SUFFIX}"
    )
endif()

add_dependencies(libevent::libevent DEPENDS libevent)