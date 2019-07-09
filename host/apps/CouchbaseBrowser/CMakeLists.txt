cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

project(CouchbaseBrowser
    VERSION 1.0.0
    LANGUAGES CXX
)

# Find the QtWidgets library
find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Widgets Core Gui Quick WebView WebEngine Qml
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SRCS
    src/DatabaseImpl.cpp
    src/Database.cpp
    src/main.cpp
)

set(HEADERS
    include/DatabaseImpl.h
    include/Database.h
)

add_executable(${PROJECT_NAME}
    ${HEADERS}
)

target_sources(${PROJECT_NAME} PRIVATE
    ${SRCS}
    qmlui.qrc
)

target_link_libraries(${PROJECT_NAME}
    couchbase-lite-cpp
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::Gui
    Qt5::Widgets
    Qt5::WebEngine
    Qt5::WebView
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

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
        resources/icons/app/app.icns
    )
    set_source_files_properties(
        resources/icons/app/app.icns
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )

    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/resources/Info.plist.in
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist
        @ONLY
    )
endif()

set(PRODUCT_NAME_LONG "Couchbase Browser")
set(PRODUCT_NAME_COPYRIGHT "Copyright (C) 2019 ON Semiconductor")
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "${PRODUCT_NAME_LONG}"
)

if(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist"
        MACOSX_BUNDLE_BUNDLE_NAME "${PRODUCT_NAME_LONG}"
        MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
        MACOSX_BUNDLE_COPYRIGHT "${PRODUCT_NAME_COPYRIGHT}"
        MACOSX_BUNDLE_GUI_IDENTIFIER com.onsemi.strata.cbb
        MACOSX_BUNDLE_ICON_FILE app.icns
        MACOSX_BUNDLE_INFO_STRING ${PRODUCT_NAME_LONG}
    )
endif()

# Add cbtest library for testing purpose
add_library(cbtest
    ${HEADERS}
)

target_sources(cbtest PRIVATE
    ${SRCS}
    qmlui.qrc
)

target_link_libraries(cbtest
    couchbase-lite-cpp
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::Gui
    Qt5::Widgets
    Qt5::WebEngine
    Qt5::WebView
)

target_include_directories(cbtest
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

if(APPLE)
    find_library(IOKIT_LIB IOKit REQUIRED)
    if (NOT IOKIT_LIB)
        message(FATAL_ERROR "IOKit framework not found")
    endif()
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()
    target_link_libraries(cbtest
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
    )
endif()

add_subdirectory(test)
