#
# googletest
#

if(BUILD_TESTING)
    get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/googletest" "${EXTERN_INSTALL_DIR_PATH}/gtest")
    if(NOT LIB_INSTALLED)
        file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/include)
        file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib)
        ExternalProject_Add(gtest
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/googletest
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -Dgtest_force_shared_crt=YES
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        )
    endif()

    add_library(gtest::gtest STATIC IMPORTED GLOBAL)
    set_target_properties(gtest::gtest PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG  "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtestd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )

    add_dependencies(gtest::gtest DEPENDS gtest)

    add_library(gtest::gmock STATIC IMPORTED GLOBAL)
    set_target_properties(gtest::gmock PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG  "${EXTERN_INSTALL_DIR_PATH}/gtest-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmockd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )

    add_dependencies(gtest::gmock DEPENDS gtest)
endif()
