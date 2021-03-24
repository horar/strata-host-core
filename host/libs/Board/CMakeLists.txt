project(Board
    VERSION 2.0
    LANGUAGES CXX
)

set(PLATFORM "Platform")
set(PLATFORM_MANAGER "PlatformManager")

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

# Platform
add_library(${PLATFORM}
    Platform/src/Device.cpp
    Platform/src/logging/LoggingQtCategories.cpp
    Platform/src/Serial/SerialDevice.cpp
    Platform/src/Mock/MockDevice.cpp
    Platform/src/Mock/MockDeviceControl.cpp

    Platform/src/Operations/Commands/BasePlatformCommand.cpp
    Platform/src/Operations/Commands/CmdGetFirmwareInfo.cpp
    Platform/src/Operations/Commands/CmdRequestPlatformId.cpp
    Platform/src/Operations/Commands/CmdStartBootloader.cpp
    Platform/src/Operations/Commands/CmdStartFlash.cpp
    Platform/src/Operations/Commands/CmdFlash.cpp
    Platform/src/Operations/Commands/CmdStartBackupFirmware.cpp
    Platform/src/Operations/Commands/CmdBackupFirmware.cpp
    Platform/src/Operations/Commands/CmdStartApplication.cpp
    Platform/src/Operations/Commands/CmdSetPlatformId.cpp
    Platform/src/Operations/Commands/CmdSetAssistedPlatformId.cpp
    Platform/src/Operations/Commands/CmdWait.cpp

    Platform/src/Operations/BasePlatformOperation.cpp
    Platform/src/Operations/Identify.cpp
    Platform/src/Operations/StartBootloader.cpp
    Platform/src/Operations/Flash.cpp
    Platform/src/Operations/Backup.cpp
    Platform/src/Operations/StartApplication.cpp
    Platform/src/Operations/SetPlatformId.cpp
    Platform/src/Operations/SetAssistedPlatformId.cpp

    #AUTOMOC wont find header if it is in different directory
    Platform/include/Device.h
    Platform/include/Serial/SerialDevice.h
    Platform/include/Mock/MockDevice.h
    Platform/include/Mock/MockDeviceControl.h
    Platform/include/Mock/MockDeviceConstants.h

    Platform/include/Operations/BasePlatformOperation.h
    Platform/include/Operations/Identify.h
)
add_library(strata::${PLATFORM} ALIAS ${PLATFORM})

target_include_directories(${PLATFORM}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/Platform/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Platform/src
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Platform/src/Serial
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Platform/src/Mock
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Platform/src/Operations
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Platform/src/Operations/Commands
)

target_link_libraries(${PLATFORM}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC rapidjson::rapidjson
    PUBLIC strata::QtLogger
    PRIVATE strata::CommandValidator
    PRIVATE strata::base64
    PRIVATE strata::crc16
)

target_compile_definitions(${PLATFORM} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

set_target_properties(${PLATFORM} PROPERTIES
    AUTOMOC ON
)

# PlatformManager
add_library(${PLATFORM_MANAGER}
    PlatformManager/src/PlatformManager.cpp
    PlatformManager/src/logging/LoggingQtCategories.cpp

    #AUTOMOC wont find header if it is in different directory
    PlatformManager/include/PlatformManager.h
)
add_library(strata::${PLATFORM_MANAGER} ALIAS ${PLATFORM_MANAGER})

target_include_directories(${PLATFORM_MANAGER}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/PlatformManager/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/PlatformManager/include
)

target_link_libraries(${PLATFORM_MANAGER}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC strata::QtLogger
    PUBLIC strata::Platform
    PRIVATE strata::CommandValidator
)

target_compile_definitions(${PLATFORM_MANAGER} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

set_target_properties(${PLATFORM_MANAGER} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_subdirectory(PlatformManager/test)
endif()
