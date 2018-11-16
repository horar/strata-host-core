cmake_minimum_required(VERSION 3.11 FATAL_ERROR)

if(APPLE)
     if(NOT CMAKE_OSX_DEPLOYMENT_TARGET)
        set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "" FORCE)
    endif()
endif()

project(SerialConsoleInterface
    LANGUAGES CXX
    VERSION 0.0.0
)

set(HOST_PATH "${CMAKE_SOURCE_DIR}/..")
set(SHARED_DIR "${HOST_PATH}/../shared")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

include(FeatureSummary)

add_subdirectory(${HOST_PATH}/Flasher ${CMAKE_CURRENT_BINARY_DIR}/Flasher)

find_package(Qt5 5.11 REQUIRED COMPONENTS
    Core
    Quick
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
endif()

list(APPEND QML_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
list(APPEND QML_DIRS ":/")
set(QML_IMPORT_PATH "${QML_DIRS}"
    CACHE STRING "Qt Creator extra qml import paths" FORCE
)

add_executable(${PROJECT_NAME} WIN32
    main.cpp
    PlatformController.cpp
    qml.qrc
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick

    connector
    #flasher

    ${IOKIT_LIB}
    ${FOUNDATION_LIB}
)

# FIXME: don't hardcode includes from 3rd party libs!!
target_include_directories(${PROJECT_NAME} SYSTEM
    PRIVATE ${HOST_PATH}/hcs2/connector/include
    PRIVATE ${HOST_PATH}/hcs2/include
    PRIVATE ${HOST_PATH}/hcs2/
    PRIVATE ${HOST_PATH}/include/macos/libserial
    PRIVATE ${HOST_PATH}/include/macos/libzmq
    PRIVATE ${SHARED_DIR}/rapidjson/include/
    PRIVATE ${SHARED_DIR}/bootloader/include
    PRIVATE ${HOST_PATH}/include/
)

# FIXME: don't hardcode libraries from 3rd party libs!!
if(APPLE)
    target_link_libraries(${PROJECT_NAME}
    -L${HOST_PATH}/lib/macos/libzmq/
    zmq
    -L${HOST_PATH}/lib/macos/libserial
    serialport
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
