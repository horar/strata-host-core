project(component-views
    LANGUAGES NONE
)

include(MacroAddView)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

file(GLOB VIEW_FOLDERS *)
foreach(VIEW_DIR ${VIEW_FOLDERS})
    if(IS_DIRECTORY ${VIEW_DIR})
        get_filename_component(VIEW_NAME ${VIEW_DIR} NAME_WE)
        add_subdirectory(${VIEW_NAME})
    endif()
endforeach()
