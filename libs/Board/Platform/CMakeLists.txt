##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(Platform
    VERSION 1.0
    LANGUAGES CXX
)

if(APPS_CORESW_SDS_PLUGIN_BLE)
    set(CONDITIONAL_PACKAGES
        Bluetooth
    )
    set(CONDITIONAL_SOURCE_FILES
        src/BluetoothLowEnergy/BluetoothLowEnergyDevice.cpp
        src/BluetoothLowEnergy/BluetoothLowEnergyJsonEncoder.cpp
        src/BluetoothLowEnergy/BluetoothLowEnergyControllerFactory.cpp
        src/BluetoothLowEnergy/BluetoothLowEnergyController.cpp
        include/BluetoothLowEnergy/BluetoothLowEnergyDevice.h
        include/BluetoothLowEnergy/BluetoothLowEnergyJsonEncoder.h
        include/BluetoothLowEnergy/BluetoothLowEnergyControllerFactory.h
        include/BluetoothLowEnergy/BluetoothLowEnergyController.h
    )
    set(CONDITIONAL_LIBRARIES
        PUBLIC Qt5::Bluetooth
    )
    add_compile_definitions(APPS_CORESW_SDS_PLUGIN_BLE=true)
endif()

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort Network ${CONDITIONAL_PACKAGES}
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/Device.cpp
    src/Platform.cpp
    src/PlatformMessage.cpp
    src/PlatformmessageData.cpp
    src/logging/LoggingQtCategories.cpp
    src/Serial/SerialDevice.cpp
    src/Mock/MockDevice.cpp
    src/Mock/MockDeviceControl.cpp
    src/Tcp/TcpDevice.cpp
    src/Operations/Commands/BasePlatformCommand.cpp
    src/Operations/Commands/CmdGetFirmwareInfo.cpp
    src/Operations/Commands/CmdRequestPlatformId.cpp
    src/Operations/Commands/CmdStartBootloader.cpp
    src/Operations/Commands/CmdStartFlash.cpp
    src/Operations/Commands/CmdFlash.cpp
    src/Operations/Commands/CmdStartBackupFirmware.cpp
    src/Operations/Commands/CmdBackupFirmware.cpp
    src/Operations/Commands/CmdStartApplication.cpp
    src/Operations/Commands/CmdSetPlatformId.cpp
    src/Operations/Commands/CmdSetAssistedPlatformId.cpp
    src/Operations/Commands/CmdWait.cpp

    src/Operations/BasePlatformOperation.cpp
    src/Operations/Identify.cpp
    src/Operations/StartBootloader.cpp
    src/Operations/Flash.cpp
    src/Operations/Backup.cpp
    src/Operations/StartApplication.cpp
    src/Operations/SetPlatformId.cpp
    src/Operations/SetAssistedPlatformId.cpp
    src/Operations/PlatformOperations.cpp

    #AUTOMOC wont find header if it is in different directory
    include/Device.h
    include/Platform.h
    include/PlatformMessage.h
    include/Serial/SerialDevice.h
    include/Mock/MockDevice.h
    include/Mock/MockDeviceControl.h
    include/Mock/MockDeviceConstants.h
    include/Tcp/TcpDevice.h
    include/Operations/BasePlatformOperation.h
    include/Operations/Identify.h
    include/Operations/PlatformOperations.h

    ${CONDITIONAL_SOURCE_FILES}
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Serial
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Mock
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Operations
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Operations/Commands
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Tcp
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC Qt5::Network
    PUBLIC rapidjson::rapidjson
    PUBLIC strata::QtLogger
    PRIVATE strata::CommandValidator
    PRIVATE strata::base64
    PRIVATE strata::crc16

    ${CONDITIONAL_LIBRARIES}
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_compile_definitions(BUILD_TESTING)
endif()
