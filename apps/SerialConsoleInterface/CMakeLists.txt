##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(SerialConsoleInterface
    DESCRIPTION "Serial Console Interface"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/sci-logo.ico)
set(PROJECT_MACOS_ICNS sci-logo.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.sci)
if(APPS_FEATURE_BLE)
    string(CONCAT PROJECT_BUNDLE_ADDON
        "<key>NSBluetoothAlwaysUsageDescription</key>"
        "<string>Bluetooth access is necessary to communicate with Bluetooth Low Energy devices</string>"
    )
    set(BLUETOOTH_SOURCES
        SciBleDeviceModel.cpp
    )
endif()
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2022 ${PROJECT_COMPANY}")


set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick
    REQUIRED
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    main.cpp
    SciModel.cpp
    SciPlatformModel.cpp
    SciPlatform.cpp
    SciScrollbackModel.cpp
    SciCommandHistoryModel.cpp
    SciFilterSuggestionModel.cpp
    SciPlatformSettings.cpp
    SciMockDevice.cpp
    SciMockDeviceModel.cpp
    SciMockCommandModel.cpp
    SciMockResponseModel.cpp
    SciMockVersionModel.cpp
    HexModel.cpp
    SciFilterScrollbackModel.cpp
    SciSearchScrollbackModel.cpp
    SciMessageQueueModel.cpp
    SciPlatformTests.cpp
    SciPlatformTestModel.cpp
    SciPlatformTestMessageModel.cpp
    qml.qrc
    images/images.qrc

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc

    ${BLUETOOTH_SOURCES}
)

set(${PROJECT_NAME}_ENABLED_PLUGINS "")
add_qml_debug_plugin_to_version(PROJ_NAME ${PROJECT_NAME} PLUGIN_NAME "qmldebug")

generate_app_version(GITTAG_PREFIX "sci_" MACBUNDLE ON)
generate_app_build_timestamp()

if(APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/sci-logo.icns
    )
    set_source_files_properties(
        resources/icons/app/sci-logo.icns
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )
endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick
    strata::PlatformManager
    strata::PlatformValidation
    strata::FlasherConnector
    strata::QtLogger
    strata::SGUtilsCpp
    strata::SGJsonSyntaxHighlighter
    strata::SGTextHighlighter
    strata::SGSortFilterProxyModel
    strata::SGCore
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<IF:$<CONFIG:OTA>,packages/${PROJECT_BUNDLE_ID}/data,bin>
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
