project(Board
    VERSION 1.0
    LANGUAGES CXX
)

set(DEVICE "Device")

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
    Device/DeviceProperties.h
    Device/Serial/SerialDevice.h
)

target_include_directories(${DEVICE}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Device/src
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Device/Serial/src
)

target_link_libraries(${DEVICE}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC QtLogger
)

set_target_properties(${DEVICE} PROPERTIES
    AUTOMOC ON
)
