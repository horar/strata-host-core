project(PlatformInterfaceGenerator
    DESCRIPTION "Platform Interface Generator"
    LANGUAGES CXX
)

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

    qml.qrc
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::Quick
    PUBLIC Qt5::Qml
    PUBLIC Qt5::Widgets

    PUBLIC strata::SGUtilsCpp
    PUBLIC rapidjson::rapidjson
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON

    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH ":/")
