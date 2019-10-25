project(CommandDocCreator
    DESCRIPTION "Command Documentation Creator"
    LANGUAGES CXX
)
set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 1)
set(PROJECT_VERSION_PATCH 0)
set(PROJECT_VERSION_TWEAK 1)
set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}.${PROJECT_VERSION_TWEAK})

message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")

set(PROJECT_COPYRIGHT "Copyright (C) 2018-2019 ${PROJECT_COMPANY}")


set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick WebEngine
    REQUIRED
)

add_executable(${PROJECT_NAME}
    main.cpp
    qml.qrc
    images/images.qrc

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc
)

if(APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/cdc-logo.icns
    )
    set_source_files_properties(
        resources/icons/app/cdc-logo.icns
        ${OPENCONNECT_VPNC_SCRIPT}
            PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )

    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/resources/Info.plist.in
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist
        @ONLY
    )
endif()
if(WIN32)
    configure_file(
        resources/commanddoccreator.rc.in
        resources/commanddoccreator.rc
        @ONLY
    )

    target_sources(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/resources/commanddoccreator.rc
    )
endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick
    Qt5::WebEngine

    QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
)

if(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist"
        MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_DESCRIPTION}"
        MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
        MACOSX_BUNDLE_COPYRIGHT "${PROJECT_COPYRIGHT}"
        MACOSX_BUNDLE_GUI_IDENTIFIER com.onsemi.strata.cdc
        MACOSX_BUNDLE_ICON_FILE cdc-logo.icns
        MACOSX_BUNDLE_INFO_STRING ${PROJECT_DESCRIPTION}
    )
endif()
if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

target_compile_definitions(${PROJECT_NAME}
#    PRIVATE QT_QML_DEBUG
    PRIVATE QT_DEPRECATED_WARNINGS
    PRIVATE QT_DISABLE_DEPRECATED_BEFORE=0x060000
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
add_qml_import_path(PATH ":/")
