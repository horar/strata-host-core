project(Devices
    VERSION 1.0
    LANGUAGES CXX
)

# Add more devices (Bluetooth, ...)

set(SERIAL_DEVICE "SerialDevice")

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

add_library(${SERIAL_DEVICE}
    src/SerialDevice.cpp
    src/logging/LoggingQtCategories.cpp

    #AUTOMOC wont find header if it is in different directory
    include/DeviceProperties.h
    include/SerialDevice.h
    src/SerialDeviceConstants.h
    src/logging/LoggingQtCategories.h
)

target_include_directories(${SERIAL_DEVICE}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${SERIAL_DEVICE}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC rapidjson::rapidjson
    PUBLIC QtLogger
    PUBLIC CommandValidator
)

set_target_properties(${SERIAL_DEVICE} PROPERTIES
    AUTOMOC ON
)
