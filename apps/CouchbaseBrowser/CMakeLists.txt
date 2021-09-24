##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(CouchbaseBrowser
    DESCRIPTION "Couchbase Browser"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/app.ico)
set(PROJECT_MACOS_ICNS app.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.cbb)
set(PROJECT_COPYRIGHT "Copyright (C) 2019-2021 ${PROJECT_COMPANY}")


find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick WebEngine Qml
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_library("${PROJECT_NAME}Library"
    src/DatabaseImpl.cpp
    src/ConfigManager.cpp
    src/WindowManager.cpp
)

target_link_libraries("${PROJECT_NAME}Library"
    Qt5::Core
    Qt5::Qml

    strata::Couchbase-Lite-C
    strata::QtLogger
)

target_include_directories("${PROJECT_NAME}Library"
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    main.cpp

    qmlui.qrc
    images.qrc
)

generate_app_version(GITTAG_PREFIX "cbb_" MACBUNDLE ON)

target_link_libraries(${PROJECT_NAME}
    Qt5::Quick
    Qt5::WebEngine

    "${PROJECT_NAME}Library"
)

if(APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/app.icns
    )
    set_source_files_properties(
        resources/icons/app/app.icns
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )
endif()

set_target_properties(${PROJECT_NAME} ${PROJECT_NAME}Library PROPERTIES
    AUTOMOC ON
    AUTORCC ON
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
