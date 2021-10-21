##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(PlatformManager
    VERSION 1.0
    LANGUAGES CXX
)

if(APPS_FEATURE_BLE)
    set(BLUETOOTH_PACKAGES
        Bluetooth
    )
    set(BLUETOOTH_SOURCES
        src/BluetoothLowEnergy/BluetoothLowEnergyScanner.cpp
        include/BluetoothLowEnergy/BluetoothLowEnergyScanner.h
    )
    set(BLUETOOTH_LIBRARIES
        PUBLIC Qt5::Bluetooth
    )
    set(BLUETOOTH_LIBRARIES_WIN32
        PRIVATE Bthprops
    )
endif()

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort Network ${BLUETOOTH_PACKAGES}
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/PlatformManager.cpp
    src/DeviceScanner.cpp
    src/logging/LoggingQtCategories.cpp
    src/Serial/SerialDeviceScanner.cpp
    src/Mock/MockDeviceScanner.cpp
    src/Tcp/TcpDeviceScanner.cpp

    #AUTOMOC wont find header if it is in different directory
    include/PlatformManager.h
    include/DeviceScanner.h
    include/Serial/SerialDeviceScanner.h
    include/Mock/MockDeviceScanner.h
    include/Tcp/TcpDeviceScanner.h

    ${BLUETOOTH_SOURCES}
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Serial
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Mock
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Tcp
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC Qt5::Network
    PUBLIC strata::QtLogger
    PUBLIC strata::Platform
    PRIVATE strata::CommandValidator

    ${BLUETOOTH_LIBRARIES}
)

if(WIN32)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ws2_32

        ${BLUETOOTH_LIBRARIES_WIN32}
    )
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_compile_definitions(BUILD_TESTING)
    add_subdirectory(test)
endif()
