project(component-sgwidgets
    VERSION 0.0.0
    LANGUAGES NONE
)

add_subdirectory(qml)
add_subdirectory(src)

option(APPS_EXAMPLES "Build project examples" OFF)
add_feature_info(APPS_EXAMPLES APPS_EXAMPLES "Build project examples")
if(APPS_EXAMPLES)
    find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Quick
        REQUIRED
    )

    add_subdirectory(qml/tech/strata/sgwidgets)
endif()
