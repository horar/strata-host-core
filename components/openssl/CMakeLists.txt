if (CMAKE_BUILD_TYPE STREQUAL "OTA")
    project(OpenSSL
        DESCRIPTION "OpenSSL Libraries"
        LANGUAGES NONE
    )

    set(PROJECT_BUNDLE_ID com.onsemi.strata.openssl)

    add_custom_target(${PROJECT_NAME})
    generate_ifw_version(GITTAG_PREFIX "openssl_")
endif()

