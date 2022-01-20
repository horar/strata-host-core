##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(flasher-cli
    DESCRIPTION "Flasher CLI"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/flasher-logo.ico)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2021 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

add_executable(${PROJECT_NAME}
    src/main.cpp
    src/CliParser.cpp
    src/SerialPortList.cpp

    src/logging/LoggingQtCategories.cpp

    src/commands/Command.h
    src/commands/DeviceCommand.cpp
    src/commands/FlasherCommand.cpp
    src/commands/HelpCommand.cpp
    src/commands/InfoCommand.cpp
    src/commands/ListCommand.cpp
    src/commands/VersionCommand.cpp
    src/commands/WrongCommand.cpp
)

generate_app_version(GITTAG_PREFIX "${PROJECT_NAME}_" MACBUNDLE OFF)
generate_app_build_timestamp()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::SerialPort
    strata::QtLogger
    strata::Flasher
    strata::Platform
)

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)
