project(StrataDeveloperStudio
    DESCRIPTION "Strata Developer Studio"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/on-logo.ico)
set(PROJECT_MACOS_ICNS on-logo.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.devstudio)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2021 ${PROJECT_COMPANY}")
set(QT5_MINIMUM_VERSION 5.12.4)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Gui Widgets Quick Qml Xml WebEngine Charts RemoteObjects Svg
    REQUIRED
)

if (Qt5_VERSION VERSION_LESS QT5_MINIMUM_VERSION)
    message(FATAL_ERROR "Minimum Qt version supported is ${QT5_MINIMUM_VERSION}. Current version in use is ${Qt5_VERSION}. Please update your version via the Qt Maintenance Tool")
endif()

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
    source/SGQrcTreeModel.cpp
    source/SGQrcTreeNode.cpp
    source/SGFileTabModel.cpp
    source/SGNewControlView.cpp
    source/ResourcePath.cpp
    source/RunGuard.cpp
    source/PlatformInterfaceGenerator.cpp
    source/VisualEditorUndoStack.cpp

    source/config/Url.cpp
    source/config/ConfigFile.cpp
    source/config/AppConfig.cpp
    source/config/UrlConfig.cpp

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc
    signals/qml/tech/strata/signals/qml.qrc
    notifications/qml/tech/strata/notifications/qml.qrc
    partial-views/control-view-creator/template-views.qrc

    qml-dev-studio.qrc
    qml-dev-studio-minimal.qrc
    qml-dev-studio-resources.qrc

    source/HcsNode.cpp
    ${NODE_RO_SRCS}
)

set(${PROJECT_NAME}_ENABLED_PLUGINS "")
add_sds_plugin(PROJ_NAME ${PROJECT_NAME} PLUGIN_OPTION_SUFFIX "DEBUGBAR" PLUGIN_NAME "debugbar")
add_sds_plugin(PROJ_NAME ${PROJECT_NAME} PLUGIN_OPTION_SUFFIX "CVC" PLUGIN_NAME "cvc")

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
    strata::SGVersionUtils

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

if(WIN32)
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

set(SDS_CONFIG_PATHS_LIST)

if(IS_DIRECTORY "${STRATA_HOST_CORE_INTERNAL_PATH}/assets/config/sds")
    list(APPEND SDS_CONFIG_PATHS_LIST ${STRATA_HOST_CORE_INTERNAL_PATH}/assets/config/sds)
endif()
list(APPEND SDS_CONFIG_PATHS_LIST ${CMAKE_HOME_DIRECTORY}/assets/config/sds)

find_all_config_files("${SDS_CONFIG_PATHS_LIST}" "*.config" APPS_CORESW_SDS_CONFIG_CHOICES)

if(NOT APPS_CORESW_SDS_CONFIG)
    if("qa.config" IN_LIST APPS_CORESW_SDS_CONFIG_CHOICES)
        set(APPS_CORESW_SDS_CONFIG "qa.config" CACHE STRING "Desired SDS configuration file." FORCE)
    else()
        set(APPS_CORESW_SDS_CONFIG "template.config" CACHE STRING "Desired SDS configuration file." FORCE)
    endif()
endif()

set_property(CACHE APPS_CORESW_SDS_CONFIG PROPERTY STRINGS ${APPS_CORESW_SDS_CONFIG_CHOICES})
if(NOT APPS_CORESW_SDS_CONFIG IN_LIST APPS_CORESW_SDS_CONFIG_CHOICES)
    message(FATAL_ERROR "Specify 'APPS_CORESW_SDS_CONFIG'. Must be one of ${APPS_CORESW_SDS_CONFIG_CHOICES}")
endif()

deploy_config_file("${SDS_CONFIG_PATHS_LIST}" ${APPS_CORESW_SDS_CONFIG} "sds.config")

# LC: start 'hcs' process from strata (will be handled by strata monitor in near future)
set_source_files_properties(main.cpp source/SDSModel.cpp source/config/ConfigFile.cpp PROPERTIES
    COMPILE_DEFINITIONS "START_SERVICES;WINDOWS_INSTALLER_BUILD=$<BOOL:${WINDOWS_INSTALLER_BUILD}>"
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/signals/qml")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/notifications/qml")

if(APPS_CORESW_SDS_PLUGIN_CVC)
    get_target_property(QT_RCC_EXECUTABLE Qt5::rcc IMPORTED_LOCATION)
    if(QT_RCC_EXECUTABLE STREQUAL "")
      message(WARNING "Could not locate Qt RCC compiler executable.")
    else()
       target_compile_definitions(${PROJECT_NAME} PRIVATE -DQT_RCC_EXECUTABLE="${QT_RCC_EXECUTABLE}")
    endif()
endif()
