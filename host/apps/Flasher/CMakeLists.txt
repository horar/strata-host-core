project(flasher-cli
    VERSION 1.0.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

if(APPLE)
    find_library(IOKIT_LIB IOKit REQUIRED)
    if (NOT IOKIT_LIB)
        message(FATAL_ERROR "IOKit framework not found")
    endif()
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()
endif()

add_executable(${PROJECT_NAME}
    src/main.cpp
    src/flasher_cli.cpp
    src/flasher_cli.h
    src/logging/LoggingQtCategories.cpp
    src/logging/LoggingQtCategories.h
)

#if (APPLE)
#    target_link_libraries(${PROJECT_NAME}
#        ${IOKIT_LIB}
#        ${FOUNDATION_LIB}
#    )
#endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::SerialPort
    QtLogger
    flasher1
    SerialDevice
#    DeviceActions

)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)
