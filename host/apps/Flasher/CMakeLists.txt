project(flasher-cli
    VERSION 1.0.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

add_executable(${PROJECT_NAME}
    src/main.cpp
    src/flasher_cli.cpp
    src/flasher_cli.h
    src/logging/LoggingQtCategories.cpp
    src/logging/LoggingQtCategories.h
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::SerialPort
    QtLogger
    flasher
    SerialDevice
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)
