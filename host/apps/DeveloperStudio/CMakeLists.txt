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
    COMPONENTS Core Gui Widgets Quick Qml Xml WebEngine Charts RemoteObjects Svg
    REQUIRED
)

qt5_generate_repc(NODE_RO_SRCS ${CMAKE_SOURCE_DIR}/apps/hcs3/src/HostControllerService.rep REPLICA)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    main.cpp
    source/AppUi.cpp
    source/SDSModel.cpp
    source/DocumentManager.cpp
    source/ResourceLoader.cpp
    source/DocumentListModel.cpp
    source/DownloadDocumentListModel.cpp
    source/VersionedListModel.cpp
    source/ClassDocuments.cpp
    source/SGQrcListModel.cpp
    $<IF:$<CONFIG:Release>, source/release/ResourcePath.cpp, source/debug/ResourcePath.cpp>

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc
    signals/qml/tech/strata/signals/qml.qrc

    qml-dev-studio.qrc
    qml-dev-studio-minimal.qrc
    qml-dev-studio-resources.qrc

    $<IF:$<CONFIG:Release>, qml-dev-studio-release.qrc, qml-dev-studio-debug.qrc>

    source/HcsNode.cpp
    ${NODE_RO_SRCS}
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
    Qt5::Xml
    Qt5::WebEngine
    Qt5::RemoteObjects
    Qt5::Svg

    strata::connector
    strata::HostControllerClient
    strata::PlatformInterface
    strata::SGUtilsCpp

    strata::QtLogger
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
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<IF:$<CONFIG:OTA>,packages/${PROJECT_BUNDLE_ID}/data,bin>
)

include(ExternalProject)

# Add monaco-editor npm package
if (APPLE)
    set(MONACO_EDITOR_TAG v0.20.0)

    find_program(NPM_EXE npm)
    mark_as_advanced(NPM_EXE)
    if(NOT NPM_EXE)
        message(FATAL_ERROR "'npm' program not found; check monaco-editor documentation")
    endif()

    find_program(NODE_JS node)
    mark_as_advanced(NODE_JS)
    if(NOT NODE_JS)
        message(FATAL_ERROR "'node.js' program not found; check monaco-editor documentation")
    endif()

    ExternalProject_Add(monaco-editor-${MONACO_EDITOR_TAG}
        EXCLUDE_FROM_ALL ON

        BUILD_IN_SOURCE ON
        BUILD_ALWAYS ON

        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/partial-views/control-view-creator

        DOWNLOAD_COMMAND ${NPM_EXE} install

        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo monaco-editor was downloaded to <SOURCE_DIR>
    )

endif()

if(WIN32)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/ext_libs/libzmq/bin/windows/x64/libzmq.dll
            $<TARGET_FILE_DIR:${PROJECT_NAME}>
        COMMENT "Deploying dependant 3rd party libraries..."
        VERBATIM
    )

    get_target_property(QT_LIBRARY_DIR Qt5::Core LOCATION)
    get_filename_component(QT_LIBRARY_DIR ${QT_LIBRARY_DIR} PATH)
    get_filename_component(QT_SSL_LIBRARY_DIR "${QT_LIBRARY_DIR}/../../../Tools/OpenSSL/Win_x64//bin" ABSOLUTE)
    if(EXISTS ${QT_SSL_LIBRARY_DIR})
        message(STATUS "OpenSSL DLL's will be copyed from ${QT_SSL_LIBRARY_DIR}")
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                ${QT_SSL_LIBRARY_DIR}/libcrypto-1_1-x64.dll
                $<TARGET_FILE_DIR:${PROJECT_NAME}>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                ${QT_SSL_LIBRARY_DIR}/libssl-1_1-x64.dll
                $<TARGET_FILE_DIR:${PROJECT_NAME}>
            COMMENT "Deploying dependant 3rd party Qt OpenSSL libraries..."
            VERBATIM
        )
    else()
        message(WARNING "Please install OpenSSL coming with your Qt installer (can't find OpenSSL DLL's in '${QT_SSL_LIBRARY_DIR}'")
    endif()
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DISABLE_DEPRECATED_BEFORE=0x060000
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

# LC: start 'hcs' process from strata (will be handled by strata monitor in near future)
set_source_files_properties(main.cpp source/SDSModel.cpp PROPERTIES
    COMPILE_DEFINITIONS "START_SERVICES;WINDOWS_INSTALLER_BUILD=$<BOOL:${WINDOWS_INSTALLER_BUILD}>"
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/signals/qml")
