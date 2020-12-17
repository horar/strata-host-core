project(PlatformInterfaceGenerator
    DESCRIPTION "Platform Interface Generator"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/on-logo.ico)
set(PROJECT_MACOS_ICNS on-logo.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.pig)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2020 ${PROJECT_COMPANY}")
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Qml Widgets
    REQUIRED
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    main.cpp
    PlatformInterfaceGenerator.cpp
    DebugMenuGenerator.cpp

    qml.qrc
    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc
)

generate_app_version(GITTAG_PREFIX "pig_" MACBUNDLE ON)

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
    PUBLIC Qt5::Core
    PUBLIC Qt5::Quick
    PUBLIC Qt5::Qml
    PUBLIC Qt5::Widgets

    PUBLIC strata::SGUtilsCpp
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON

    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DISABLE_DEPRECATED_BEFORE=0x060000
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
add_qml_import_path(PATH ":/")
