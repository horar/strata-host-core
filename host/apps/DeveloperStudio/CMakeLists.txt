project(StrataDeveloperStudio
    DESCRIPTION "Strata Developer Studio"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/on.ico)
set(PROJECT_MACOS_ICNS onLogoGreen.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.devstudio)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2019 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Gui Widgets Quick Qml WebEngine Charts
    REQUIRED
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
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

    timestamp.cpp
    timestamp.cpp.in
)
set_property(SOURCE timestamp.cpp PROPERTY SKIP_AUTOMOC ON)

set_source_files_properties(
    timestamp.cpp
    PROPERTIES
        GENERATED true
)

generate_app_version(GITTAG_PREFIX "devstudio_" MACBUNDLE ON)
include(timestamp)

if(APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/onLogoGreen.icns
    )
    set_source_files_properties(
        resources/icons/app/onLogoGreen.icns
        ${OPENCONNECT_VPNC_SCRIPT}
            PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )

endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Gui
    Qt5::Widgets
    Qt5::Qml
    Qt5::WebEngine

    connector
    StrataSerialPort
    HostControllerClient
    PlatformInterface

    QtLogger
)

add_dependencies(${PROJECT_NAME}
    component-common
    component-fonts
    component-pdfjs
    component-sgwidgets
    component-theme
    component-theme
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

if(WIN32)
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

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=0x060000
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

# LC: start 'hcs' process from strata (will be handled by strata monitor in near future)
set_source_files_properties(main.cpp PROPERTIES
    COMPILE_DEFINITIONS "START_SERVICES;WINDOWS_INSTALLER_BUILD=$<BOOL:${WINDOWS_INSTALLER_BUILD}>"
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
add_qml_import_path(PATH ":/")
