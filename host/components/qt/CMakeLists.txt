if (CMAKE_BUILD_TYPE STREQUAL "OTA")
    project(Qt
        DESCRIPTION "Qt components"
        LANGUAGES NONE
    )

    set(PROJECT_BUNDLE_ID com.onsemi.strata.qt)

    add_custom_target(${PROJECT_NAME})
    generate_ifw_version(GITTAG_PREFIX "qt_")
endif()

