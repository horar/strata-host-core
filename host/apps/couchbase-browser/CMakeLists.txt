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
#set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SRCS
    src/databaseinterface.cpp
    src/databaseinterface.h
    src/main.cpp
)

add_executable(${PROJECT_NAME})
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
