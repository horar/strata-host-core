project(StrataDeveloperStudio
    DESCRIPTION "Strata Developer Studio"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/on-logo.ico)
set(PROJECT_MACOS_ICNS on-logo.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.devstudio)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2020 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Gui Widgets Quick Qml WebEngine Charts
    REQUIRED
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    main.cpp
    source/DocumentManager.cpp
    source/ResourceLoader.cpp
    source/DocumentListModel.cpp
    source/DownloadDocumentListModel.cpp
    $<IF:$<CONFIG:Release>, source/release/ResourcePath.cpp, source/debug/ResourcePath.cpp>

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc

    qml-dev-studio.qrc
    qml-dev-studio-minimal.qrc
    qml-dev-studio-resources.qrc

    $<IF:$<CONFIG:Release>, qml-dev-studio-release.qrc, qml-dev-studio-debug.qrc>
)

generate_app_version(GITTAG_PREFIX "devstudio_" MACBUNDLE ON)
generate_app_build_timestamp()

if(APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/on-logo.icns
    )
    set_source_files_properties(
        resources/icons/app/on-logo.icns
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
    QT_DISABLE_DEPRECATED_BEFORE=0x060000
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

# LC: start 'hcs' process from strata (will be handled by strata monitor in near future)
set_source_files_properties(main.cpp PROPERTIES
    COMPILE_DEFINITIONS "START_SERVICES;WINDOWS_INSTALLER_BUILD=$<BOOL:${WINDOWS_INSTALLER_BUILD}>;HCS_CONFIG=$<IF:$<CONFIG:Release>,\"hcs.config\",\"hcs_qa.config\">"
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
add_qml_import_path(PATH ":/")
