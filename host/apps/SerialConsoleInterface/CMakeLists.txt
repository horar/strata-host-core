
project(SerialConsoleInterface
    LANGUAGES CXX
    VERSION 0.1.0
)
message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick
    REQUIRED
)

add_executable(${PROJECT_NAME}
    main.cpp
    SciModel.cpp
    BoardsController.cpp
    PlatformBoard.cpp
    ProgramDeviceTask.cpp
    SgUtilsCpp.cpp
    qml.qrc
    images/images.qrc
)

if(APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/sciLogoGreen.icns
    )
    set_source_files_properties(
        resources/icons/app/sciLogoGreen.icns
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
        resources/serialconsoleinterface.rc
    )
endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick
    PlatformManager
    flasher
)

set(PRODUCT_NAME_LONG "Serial Console Interface")
set(PRODUCT_NAME_COPYRIGHT "Copyright (C) 2019 On Semiconductor")

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
        MACOSX_BUNDLE_ICON_FILE sciLogoGreen.icns
        MACOSX_BUNDLE_INFO_STRING ${PRODUCT_NAME_LONG}
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

list(APPEND QML_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
list(APPEND QML_DIRS ":/")
set(QML_IMPORT_PATH "${QML_DIRS}"
    CACHE STRING "Qt Creator extra qml import paths" FORCE
)
