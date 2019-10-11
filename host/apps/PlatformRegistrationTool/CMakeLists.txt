project(PlatformRegistrationTool
    DESCRIPTION "Platform Registration Tool"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/prt-logo.ico)
set(PROJECT_MACOS_ICNS prt-logo.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.prt)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2019 ${PROJECT_COMPANY}")


set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Qml
    REQUIRED
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE)
target_sources(${PROJECT_NAME} PRIVATE
    main.cpp
    PrtModel.cpp
    images/images.qrc
    qml.qrc

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc
)

generate_app_version(GITTAG_PREFIX "prt_" MACBUNDLE ON)

if(APPLE)
    find_library(IOKIT_LIB IOKit REQUIRED)
    if (NOT IOKIT_LIB)
        message(FATAL_ERROR "IOKit framework not found")
    endif()
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()

    target_link_libraries(${PROJECT_NAME}
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
    )

    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/prt-logo.icns
    )
    set_source_files_properties(
        resources/icons/app/prt-logo.icns
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )
endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Qml
    Qt5::Quick

    BoardsController
    QtLogger
)

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
)

target_compile_definitions(${PROJECT_NAME}
#    PRIVATE QT_QML_DEBUG
    PRIVATE QT_DEPRECATED_WARNINGS
    PRIVATE QT_DISABLE_DEPRECATED_BEFORE=0x060000
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
add_qml_import_path(PATH ":/")
