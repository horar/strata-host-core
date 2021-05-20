if (CMAKE_BUILD_TYPE STREQUAL "OTA")
    project(Addons
        DESCRIPTION "Strata Addons"
        LANGUAGES NONE
    )

    set(PROJECT_BUNDLE_ID com.onsemi.strata.addons)

    add_custom_target(${PROJECT_NAME})
    generate_ifw_version(GITTAG_PREFIX "addons_")
endif()

