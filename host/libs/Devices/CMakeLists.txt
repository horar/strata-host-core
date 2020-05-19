project(Devices
    VERSION 1.0
    LANGUAGES CXX
)

set(DEVICE_OPERATIONS "DeviceOperations")

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

# DeviceOperations
add_library(${DEVICE_OPERATIONS}
    src/DeviceOperations.cpp
    src/logging/LoggingQtCategories.cpp
    src/DeviceCommands/BaseDeviceCommand.cpp
    src/DeviceCommands/CmdGetFirmwareInfo.cpp
    src/DeviceCommands/CmdRequestPlatformId.cpp
    src/DeviceCommands/CmdUpdateFirmware.cpp
    src/DeviceCommands/CmdFlashFirmware.cpp
    src/DeviceCommands/CmdBackupFirmware.cpp
    src/DeviceCommands/CmdStartApplication.cpp

    #AUTOMOC wont find header if it is in different directory
    include/DeviceOperations.h
    include/DeviceOperationsFinished.h
)

target_include_directories(${DEVICE_OPERATIONS}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${DEVICE_OPERATIONS}
    PUBLIC Qt5::Core
    PUBLIC Device
    PUBLIC rapidjson::rapidjson
    PUBLIC QtLogger
    PRIVATE CommandValidator
    PRIVATE base64
    PRIVATE crc16
)

set_target_properties(${DEVICE_OPERATIONS} PROPERTIES
    AUTOMOC ON
)
