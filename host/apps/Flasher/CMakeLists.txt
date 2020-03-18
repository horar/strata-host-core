project(flasher-cli
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_executable(${PROJECT_NAME}
    src/main.cpp
    src/FlasherCli.cpp
    src/FlasherCli.h
    src/logging/LoggingQtCategories.cpp
    src/logging/LoggingQtCategories.h
)

generate_app_version(GITTAG_PREFIX "${PROJECT_NAME}_" MACBUNDLE OFF)

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
