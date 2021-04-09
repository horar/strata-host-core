#
# couchbaselitecpp and couchbase litecore
#

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/couchbase-lite-cpp" "${EXTERN_INSTALL_DIR_PATH}/cblitecpp")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib)
    if(NOT WIN32)
        ExternalProject_Add(cblitecpp
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-cpp
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DBUILD_EXAMPLES=${BUILD_EXAMPLES}
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DSSL_LIB="$<$<NOT:$<CONFIG:OTA>>:${SSL_LIB_PATH_MACOS}/lib/>libssl.1.1.dylib"
                -DCRYPTO_LIB="$<$<NOT:$<CONFIG:OTA>>:${SSL_LIB_PATH_MACOS}/lib/>libcrypto.1.1.dylib"

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreREST_Static${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib

            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/3rd_party/include/litecore <INSTALL_DIR>/include/litecore
            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/3rd_party/include/fleece <INSTALL_DIR>/include/fleece
        )
    else()
        ExternalProject_Add(cblitecpp
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-cpp
            EXCLUDE_FROM_ALL ON
            CMAKE_ARGS "${CMAKE_ARGS}"
                -DBUILD_EXAMPLES=${BUILD_EXAMPLES}
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DSSL_LIB="libssl-1_1-x64.dll"
                -DCRYPTO_LIB="libcrypto-1_1-x64.dll"

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreREST_Static${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic$<$<CONFIG:Debug>:d>${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/3rd_party/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib

            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/3rd_party/include/litecore <INSTALL_DIR>/include/litecore
            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/3rd_party/include/fleece <INSTALL_DIR>/include/fleece
        )
    endif()
endif()

add_library(strata::CouchbaseLiteCPP STATIC IMPORTED GLOBAL)
set_target_properties(strata::CouchbaseLiteCPP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}couchbaselitecpp${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(strata::CouchbaseLiteCPP DEPENDS cblitecpp)

add_library(cblitecore::LiteCore STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::LiteCore PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::LiteCore DEPENDS cblitecpp)

add_library(cblitecore::Fleece STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::Fleece PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::Fleece DEPENDS cblitecpp)

add_library(cblitecore::CivetWeb STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::CivetWeb PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CivetWeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::CivetWeb DEPENDS cblitecpp)

add_library(cblitecore::BLIP STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::BLIP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cblitecore::BLIP DEPENDS cblitecpp)

add_library(cblitecore::support STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::support PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Support${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cblitecore::SQLite3_unicode STATIC IMPORTED GLOBAL)
set_target_properties(cblitecore::SQLite3_unicode PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(cblitecore::SQLite3_unicode DEPENDS cblitecpp)

if(WIN32)
    add_library(cblitecore::zlib STATIC IMPORTED GLOBAL)
    set_target_properties(cblitecore::zlib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
        IMPORTED_LOCATION       "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstaticd${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(cblitecore::zlib DEPENDS cblitecpp)

    add_library(cblitecore::mbedtls STATIC IMPORTED GLOBAL)
    set_target_properties(cblitecore::mbedtls PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cblitecpp-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(cblitecore::mbedtls DEPENDS cblitecpp)
endif()

target_link_libraries(strata::CouchbaseLiteCPP
    INTERFACE
        cblitecore::LiteCore
        cblitecore::Fleece
        cblitecore::CivetWeb
        cblitecore::BLIP
        cblitecore::SQLite3_unicode
        cblitecore::support
)
if(WIN32)
    target_link_libraries(strata::CouchbaseLiteCPP
        INTERFACE
            cblitecore::zlib
            cblitecore::mbedtls
    )
else()
    target_link_libraries(strata::CouchbaseLiteCPP
        INTERFACE
            z
    )
endif()

if(APPLE)
    find_library(IOKIT_LIB IOKit REQUIRED)
    if (NOT IOKIT_LIB)
        message(FATAL_ERROR "IOKit framework not found")
    endif()
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()

    target_link_libraries(strata::CouchbaseLiteCPP INTERFACE
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
    )
endif()
