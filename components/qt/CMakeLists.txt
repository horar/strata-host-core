if (CMAKE_BUILD_TYPE STREQUAL "OTA")
    project(Qt
        DESCRIPTION "Qt5 Framework"
        LANGUAGES NONE
    )

    set(PROJECT_BUNDLE_ID com.onsemi.strata.qt)

    # LC: only to load a Qt version to 'Qt5Core_VERSION_STRING' variable
    find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Core
        REQUIRED
    )

    add_custom_target(${PROJECT_NAME})
    generate_ifw_version(GITTAG_PREFIX "qt_")
endif()

