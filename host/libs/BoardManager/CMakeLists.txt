project(BoardManager
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/BoardManager.cpp
    src/SerialDevice.cpp
    src/logging/LoggingQtCategories.cpp

    #AUTOMOC wont find header if it is in different directory
    include/BoardManager.h
    include/BoardManagerConstants.h
    include/SerialDevice.h
    include/SerialDeviceConstants.h
    src/logging/LoggingQtCategories.h
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    rapidjson::rapidjson
    PUBLIC QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)
