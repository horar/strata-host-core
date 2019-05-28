include(MacroAddSgWidgetExample)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

file(GLOB SGWIDGETS_FOLDERS SG*)
foreach(SGWIDGET_DIR ${SGWIDGETS_FOLDERS})
    if(IS_DIRECTORY ${SGWIDGET_DIR})
        get_filename_component(SGWIDGETS_NAME ${SGWIDGET_DIR} NAME_WE)
        add_subdirectory(${SGWIDGETS_NAME})
    endif()
endforeach()

