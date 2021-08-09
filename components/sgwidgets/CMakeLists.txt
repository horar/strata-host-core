add_subdirectory(qml)

if(BUILD_EXAMPLES)
    find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Quick
        REQUIRED
    )

    add_subdirectory(qml/tech/strata/sgwidgets)
    add_subdirectory(qml/tech/strata/sgwidgets.1.0)
    add_subdirectory(qml/tech/strata/sglayout.1.0)
endif()
