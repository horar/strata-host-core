project(SGFontsGallery
    VERSION 0.0.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick
    REQUIRED
)

add_executable(${PROJECT_NAME}
    main.cpp
    qml.qrc
)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTORCC ON
)
if(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
    )
endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick
)
