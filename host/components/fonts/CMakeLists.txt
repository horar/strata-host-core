project(component-fonts
    VERSION 0.0.0
    LANGUAGES NONE
)

add_subdirectory(qml)

if(BUILD_EXAMPLES)
    add_subdirectory(src)
endif()
