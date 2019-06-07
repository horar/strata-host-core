project(component-sgwidgets
    VERSION 0.0.0
    LANGUAGES NONE
)

add_subdirectory(qml)

if(BUILD_EXAMPLES)
    add_subdirectory(src)

    find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Quick
        REQUIRED
    )

    add_subdirectory(qml/tech/strata/sgwidgets)
endif()
