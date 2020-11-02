project(SerialConsoleInterface
    DESCRIPTION "Serial Console Interface"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/sci-logo.ico)
set(PROJECT_MACOS_ICNS sci-logo.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.sci)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2020 ${PROJECT_COMPANY}")


set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick WebEngine
    REQUIRED
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    main.cpp
    SciModel.cpp
    SciDatabaseConnector.cpp
    SciPlatformModel.cpp
    SciPlatform.cpp
    SciScrollbackModel.cpp
    SciCommandHistoryModel.cpp
    SciPlatformSettings.cpp
    qml.qrc
    images/images.qrc

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc
)

generate_app_version(GITTAG_PREFIX "sci_" MACBUNDLE ON)

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
    Qt5::WebEngine
    strata::BoardManager
    strata::FlasherConnector
    strata::CouchbaseLiteCPP
    strata::QtLogger
    strata::SGUtilsCpp
    strata::SGJsonSyntaxHighlighter
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DISABLE_DEPRECATED_BEFORE=0x060000
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}/logging/qml")
