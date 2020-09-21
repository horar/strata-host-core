project(Board
    VERSION 1.0
    LANGUAGES CXX
)

set(DEVICE "Device")
set(DEVICE_OPERATIONS "DeviceOperations")
set(BOARD_MANAGER "BoardManager")

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

# Device
add_library(${DEVICE}
    Device/src/Device.cpp
    Device/src/logging/LoggingQtCategories.cpp
    Device/Serial/src/SerialDevice.cpp

    #AUTOMOC wont find header if it is in different directory
    Device/Device.h
    Device/Serial/SerialDevice.h
)
add_library(strata::${DEVICE} ALIAS ${DEVICE})

target_include_directories(${DEVICE}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Device/src
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Device/Serial/src
)

target_link_libraries(${DEVICE}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC strata::QtLogger
)

set_target_properties(${DEVICE} PROPERTIES
    AUTOMOC ON
)

# DeviceOperations
add_library(${DEVICE_OPERATIONS}
    Device/src/logging/LoggingQtCategories.cpp

    Device/Operations/Commands/src/BaseDeviceCommand.cpp
    Device/Operations/Commands/src/CmdGetFirmwareInfo.cpp
    Device/Operations/Commands/src/CmdRequestPlatformId.cpp
    Device/Operations/Commands/src/CmdStartBootloader.cpp
    Device/Operations/Commands/src/CmdStartFlash.cpp
    Device/Operations/Commands/src/CmdFlash.cpp
    Device/Operations/Commands/src/CmdStartBackupFirmware.cpp
    Device/Operations/Commands/src/CmdBackupFirmware.cpp
    Device/Operations/Commands/src/CmdStartApplication.cpp

    Device/Operations/BaseDeviceOperation.h
    Device/Operations/src/BaseDeviceOperation.cpp
    Device/Operations/src/Identify.cpp
    Device/Operations/src/StartBootloader.cpp
    Device/Operations/src/Flash.cpp
    Device/Operations/src/Backup.cpp
    Device/Operations/src/StartApplication.cpp
)
add_library(strata::${DEVICE_OPERATIONS} ALIAS ${DEVICE_OPERATIONS})

target_include_directories(${DEVICE_OPERATIONS}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/Device/Operations/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Device/src
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Device/Operations
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Device/Operations/src
)

target_link_libraries(${DEVICE_OPERATIONS}
    PUBLIC Qt5::Core
    PUBLIC strata::Device
    PUBLIC rapidjson::rapidjson
    PUBLIC strata::QtLogger
    PRIVATE strata::CommandValidator
    PRIVATE strata::base64
    PRIVATE strata::crc16
)

set_target_properties(${DEVICE_OPERATIONS} PROPERTIES
    AUTOMOC ON
)

# BoardManager
add_library(${BOARD_MANAGER}
    BoardManager/src/BoardManager.cpp
    BoardManager/src/logging/LoggingQtCategories.cpp

    #AUTOMOC wont find header if it is in different directory
    BoardManager/include/BoardManager.h
)
add_library(strata::${BOARD_MANAGER} ALIAS ${BOARD_MANAGER})

target_include_directories(${BOARD_MANAGER}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/BoardManager/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/BoardManager/include
)

target_link_libraries(${BOARD_MANAGER}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC strata::QtLogger
    PUBLIC strata::Device
    PRIVATE strata::DeviceOperations
)

set_target_properties(${BOARD_MANAGER} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_subdirectory(BoardManager/test)
endif()
