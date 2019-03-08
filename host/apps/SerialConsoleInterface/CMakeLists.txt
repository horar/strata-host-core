cmake_minimum_required(VERSION 3.1 FATAL_ERROR)
project(SerialConsoleInterface
    LANGUAGES CXX
    VERSION 0.0.0
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

include(FeatureSummary)

find_package(Qt5 5.11 COMPONENTS Core Gui Network Quick REQUIRED)
if (NOT Qt5_FOUND)
    message(FATAL_ERROR "Qt5 not found!")
endif()

if(APPLE)
    find_library(IOKIT_LIB IOKit REQUIRED)
    if (NOT IOKIT_LIB)
        message(FATAL_ERROR "IOKit framework not found")
    endif()
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()
endif()

list(APPEND QML_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
list(APPEND QML_DIRS ":/")
set(QML_IMPORT_PATH "${QML_DIRS}"
    CACHE STRING "Qt Creator extra qml import paths" FORCE
)

add_executable(${PROJECT_NAME}
    main.cpp
    BoardsController.cpp
    PlatformBoard.cpp
    qml.qrc
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick
    PlatformManager
)

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
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

if(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
    MACOSX_BUNDLE_BUNDLE_NAME "Serial Console Interface"
    )
endif()

feature_summary(WHAT ALL)
