##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(WidgetGallery
    DESCRIPTION "Widget Gallery"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/wg-logo.ico)
set(PROJECT_MACOS_ICNS wg-logo.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.wg)
set(PROJECT_COPYRIGHT "Copyright (C) 2019-2021 ${PROJECT_COMPANY}")


set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Widgets
    REQUIRED
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    main.cpp
    qml.qrc
    images/images.qrc

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc
)

generate_app_version(GITTAG_PREFIX "wg_" MACBUNDLE ON)

if(APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/wg-logo.icns
    )
    set_source_files_properties(
        resources/icons/app/wg-logo.icns
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )
endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick
    Qt5::Widgets
    strata::QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON

    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
