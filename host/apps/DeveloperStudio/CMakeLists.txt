project(StrataDeveloperStudio
    DESCRIPTION "Strata Developer Studio"
    LANGUAGES CXX
)
set(PROJECT_VERSION_MAJOR 1)
set(PROJECT_VERSION_MINOR 3)
set(PROJECT_VERSION_PATCH 0)
if("$ENV{BUILD_ID}" STREQUAL "")
    set(PROJECT_VERSION_TWEAK 1)
else()
    set(PROJECT_VERSION_TWEAK $ENV{BUILD_ID})
endif()
set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}.${PROJECT_VERSION_TWEAK})

message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")


set(PROJECT_COMPANY "ON Semiconductor")
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2019 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Gui Widgets Quick Qml WebView WebEngine Charts
    REQUIRED
)

add_executable(${PROJECT_NAME}
    main.cpp
    source/DocumentManager.cpp
    source/ResourceLoader.cpp
    $<IF:$<CONFIG:Release>, source/release/ResourcePath.cpp, source/debug/ResourcePath.cpp>

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc

    qml-dev-studio.qrc
    qml-dev-studio-minimal.qrc
    qml-dev-studio-resources.qrc

    $<IF:$<CONFIG:Release>, qml-dev-studio-release.qrc, qml-dev-studio-debug.qrc>
)
if(APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/onLogoGreen.icns
    )
    set_source_files_properties(
        resources/icons/app/onLogoGreen.icns
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
        resources/main.rc.in
        resources/main.rc
        @ONLY
    )

    target_sources(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/resources/main.rc
    )
endif()


target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Gui
    Qt5::Widgets
    Qt5::Qml
    Qt5::WebEngine
    Qt5::WebView

    connector
    flasher
    HostControllerClient
    PlatformInterface

    QtLogger
)
if(WIN32)
    target_link_libraries(${PROJECT_NAME} Shlwapi)
endif()

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/source
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
        MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
        MACOSX_BUNDLE_COPYRIGHT "${PROJECT_COPYRIGHT}"
        MACOSX_BUNDLE_GUI_IDENTIFIER com.onsemi.strata.devstudio
        MACOSX_BUNDLE_ICON_FILE onLogoGreen.icns
        MACOSX_BUNDLE_INFO_STRING ${PROJECT_DESCRIPTION}
    )
endif()

if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE ON
    )

    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/ext_libs/libzmq/bin/windows/x64/libzmq.dll
            $<TARGET_FILE_DIR:${PROJECT_NAME}>
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/ext_libs/libcurl/bin/windows/x64/libcurl.dll
            $<TARGET_FILE_DIR:${PROJECT_NAME}>
        COMMENT "Deploying dependant 3rd party libraries..."
        VERBATIM
    )
endif()

target_compile_definitions(${PROJECT_NAME}
#    PRIVATE QT_QML_DEBUG
    PRIVATE QT_DEPRECATED_WARNINGS
    PRIVATE QT_DISABLE_DEPRECATED_BEFORE=0x060000
)

# LC: start 'hcs' process from strata (will be handled by strata monitor in near future)
set_source_files_properties(main.cpp PROPERTIES
    COMPILE_DEFINITIONS "START_SERVICES;WINDOWS_INSTALLER_BUILD=$<BOOL:${WINDOWS_INSTALLER_BUILD}>"
)

include(MacroAddQmlImportPath)
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
add_qml_import_path(PATH ":/")
