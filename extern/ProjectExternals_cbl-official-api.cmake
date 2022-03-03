##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# Couchbase-Lite-C (official API)
#

get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/couchbase-lite-C" "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib)
    if(NOT WIN32)
        ExternalProject_Add(cb-lite-c
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-C
            EXCLUDE_FROM_ALL ON

            # Apply patches
            PATCH_COMMAND cd ${SOURCE_DIR_EXTERN}/.. && git submodule --quiet update --force --recursive extern/couchbase-lite-C
            COMMAND cd ${SOURCE_DIR_EXTERN}/couchbase-lite-C && git apply -v ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-c/cb-lite-c.patch ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-c/cb-lite-core.patch

            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install

            # Couchbase-Lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # LiteCore
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # BLIP
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/Networking/BLIP/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # Fleece
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/fleece/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # MbedTLS
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls-O${CMAKE_STATIC_LIBRARY_SUFFIX}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509-O${CMAKE_STATIC_LIBRARY_SUFFIX}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/crypto/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # SQLite3_Unicode
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/sqlite3-unicodesn/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # CouchbaseSqlite3
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/include/cbl++ <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/include/cbl <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/src <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/vendor/couchbase-lite-core/vendor/fleece/API/fleece <INSTALL_DIR>/include/fleece
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/vendor/couchbase-lite-core/vendor/fleece/Fleece/Support <INSTALL_DIR>/include/fleece
        )
    else()
        ExternalProject_Add(cb-lite-c
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/couchbase-lite-C
            EXCLUDE_FROM_ALL ON

            # Apply patches
            PATCH_COMMAND cd ${SOURCE_DIR_EXTERN}/.. && git submodule --quiet update --force --recursive extern/couchbase-lite-C
            COMMAND cd ${SOURCE_DIR_EXTERN}/couchbase-lite-C && git apply -v ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-c/cb-lite-c.patch ${CMAKE_SOURCE_DIR}/extern/patches/couchbase-lite-c/cb-lite-core.patch

            CMAKE_ARGS "${CMAKE_ARGS}"
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install

            # Couchbase-Lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # LiteCore
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # BLIP
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/Networking/BLIP/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # Fleece
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/fleece/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # MbedTLS
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls-O${CMAKE_STATIC_LIBRARY_SUFFIX}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509-O${CMAKE_STATIC_LIBRARY_SUFFIX}
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/mbedtls/crypto/library/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # SQLite3_Unicode
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/vendor/sqlite3-unicodesn/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # CouchbaseSqlite3
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            # zlib
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/vendor/couchbase-lite-core/Networking/BLIP/vendor/zlib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic$<$<CONFIG:Debug>:d>${CMAKE_STATIC_LIBRARY_SUFFIX} <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}

            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/include/cbl++ <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/include/cbl <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/src <INSTALL_DIR>/include/couchbase-lite-C
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/vendor/couchbase-lite-core/vendor/fleece/API/fleece <INSTALL_DIR>/include/fleece
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR_EXTERN}/couchbase-lite-C/vendor/couchbase-lite-core/vendor/fleece/Fleece/Support <INSTALL_DIR>/include/fleece
        )
    endif()
endif()

add_library(strata::Couchbase-Lite-C STATIC IMPORTED GLOBAL)
set_target_properties(strata::Couchbase-Lite-C PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseLiteCStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(strata::Couchbase-Lite-C DEPENDS cb-lite-c)

add_library(cb-lite-c::LiteCore STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::LiteCore PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cb-lite-c::LiteCore DEPENDS strata::Couchbase-Lite-C)

add_library(cb-lite-c::CouchbaseSqlite3 STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::CouchbaseSqlite3 PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}CouchbaseSqlite3-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cb-lite-c::CouchbaseSqlite3 DEPENDS strata::Couchbase-Lite-C)

add_library(cb-lite-c::Fleece STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::Fleece PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}FleeceStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
add_dependencies(cb-lite-c::Fleece DEPENDS strata::Couchbase-Lite-C)

add_library(cb-lite-c::BLIP STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::BLIP PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}BLIPStatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::SQLite3_unicode STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::SQLite3_unicode PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}SQLite3_UnicodeSN-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::mbedcrypto STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::mbedcrypto PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedcrypto-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::mbedtls STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::mbedtls PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedtls-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::mbedx509 STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::mbedx509 PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}mbedx509-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::LiteCoreWebSocket STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::LiteCoreWebSocket PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
    IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}LiteCoreWebSocket-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_library(cb-lite-c::sockpp STATIC IMPORTED GLOBAL)
set_target_properties(cb-lite-c::sockpp PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
)

if(WIN32)
    add_library(zlib STATIC IMPORTED GLOBAL)
    set_target_properties(zlib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/include"
        IMPORTED_LOCATION  "${EXTERN_INSTALL_DIR_PATH}/cbl-official-api-${GIT_HASH}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}zlibstatic-O${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    add_dependencies(zlib DEPENDS strata::Couchbase-Lite-C)
endif()

if(APPLE)
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    target_link_libraries(cb-lite-c::LiteCore INTERFACE "-framework Security")
endif()

target_link_libraries(strata::Couchbase-Lite-C
    INTERFACE
        cb-lite-c::LiteCore
        cb-lite-c::Fleece
        cb-lite-c::BLIP
        cb-lite-c::SQLite3_unicode
        cb-lite-c::mbedcrypto
        cb-lite-c::mbedtls
        cb-lite-c::mbedx509
        cb-lite-c::LiteCoreWebSocket
        cb-lite-c::CouchbaseSqlite3
)

if(APPLE)
    target_link_libraries(strata::Couchbase-Lite-C INTERFACE z ${FOUNDATION_LIB})
endif()

if(WIN32)
    target_link_libraries(strata::Couchbase-Lite-C INTERFACE zlib wsock32 ws2_32)
endif()
