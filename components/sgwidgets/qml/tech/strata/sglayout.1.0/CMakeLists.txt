include(AddSgWidgetExampleMacro)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

file(GLOB SGLAYOUT_FOLDERS SG*)
foreach(SGLAYOUT_DIR ${SGLAYOUT_FOLDERS})
    if(IS_DIRECTORY ${SGLAYOUT_DIR} AND EXISTS "${SGLAYOUT_DIR}/CMakeLists.txt")
        get_filename_component(SGLAYOUT_NAME ${SGLAYOUT_DIR} NAME_WE)
        add_subdirectory(${SGLAYOUT_NAME})
    endif()
endforeach()

