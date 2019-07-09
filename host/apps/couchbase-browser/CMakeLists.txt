cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

project(couchbase-browser
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
    src/databaseinterface.cpp
    src/qmlbridge.cpp
    src/main.cpp
)

set(HEADERS
    include/databaseinterface.h
    include/qmlbridge.h
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
endif()

set(PRODUCT_NAME_LONG "Couchbase Browser")
set(PRODUCT_NAME_COPYRIGHT "Copyright (C) 2019 ON Semiconductor")
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "${PRODUCT_NAME_LONG}"
)

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
