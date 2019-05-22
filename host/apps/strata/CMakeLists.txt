project(strata
    VERSION 0.0.0
    LANGUAGES CXX
)
message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Gui Widgets Quick Qml WebView WebEngine Charts
    REQUIRED
)

add_executable(${PROJECT_NAME}
    main.cpp
    source/DocumentManager.cpp

    logging/LoggingQtCategories.cpp
    logging/LoggingQtCategories.qrc

    qml-dev-studio.qrc
    qml-dev-studio-minimal.qrc
    qml-dev-studio-resources.qrc

    qml-views-15A-switcher.qrc
    qml-views-5A-switcher.qrc
    qml-views-XDFN-LDO.qrc
    qml-views-bubu.qrc
    qml-views-efficiency-simulator.qrc
    qml-views-entice_rgb.qrc
    qml-views-led.qrc
    qml-views-logic-gate.qrc
    qml-views-motor-vortex.qrc
    qml-views-template.qrc
    qml-views-usb-hub.qrc
    qml-views-usb-pd-multiport.qrc
    qml-views-usb-pd.qrc
    qml-views-subghz.qrc
    qml-views-eFuse.qrc

    views/SGPdfViewer/pdfjs.qrc
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
    target_sources(${PROJECT_NAME} PRIVATE
        resources/strata.rc
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

set(PRODUCT_NAME_LONG "Strata Developer Studio")
set(PRODUCT_NAME_COPYRIGHT "Copyright (C) 2018 On Semiconductor")
set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME "${PRODUCT_NAME_LONG}"
)
if(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist"
        MACOSX_BUNDLE_BUNDLE_NAME "${PRODUCT_NAME_LONG}"
        MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
        MACOSX_BUNDLE_COPYRIGHT "${PRODUCT_NAME_COPYRIGHT}"
        MACOSX_BUNDLE_GUI_IDENTIFIER com.onsemi.spyglass
        MACOSX_BUNDLE_ICON_FILE onLogoGreen.icns
        MACOSX_BUNDLE_INFO_STRING ${PRODUCT_NAME_LONG}
    )
endif()

if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

target_compile_options(${PROJECT_NAME}
    PRIVATE $<$<CXX_COMPILER_ID:AppleClang>:-Wall -Wextra>
)

target_compile_definitions(${PROJECT_NAME}
#    PRIVATE QT_QML_DEBUG
    PRIVATE QT_DEPRECATED_WARNINGS
    PRIVATE QT_DISABLE_DEPRECATED_BEFORE=0x060000
)

# LC: start 'hcs' process from strata (will be handled by strata monitor in near future)
set_source_files_properties(main.cpp PROPERTIES
    COMPILE_DEFINITIONS "START_SERVICES;WINDOWS_INSTALLER_BUILD=$<BOOL:${WINDOWS_INSTALLER_BUILD}>"
)

# TODO: [LC] fix this, because it need to be set in multiple Qt UI projects
list(APPEND QML_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
list(APPEND QML_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/")
set(QML_IMPORT_PATH "${QML_DIRS};${QML_IMPORT_PATH}"
    CACHE STRING "Qt Creator extra qml import paths" FORCE
)
