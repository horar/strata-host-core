project(rcc-util
    VERSION 1.0.0
    LANGUAGES CXX
)

message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")

set(PROJECT_VERSION_TWEAK "1") # LC: temporary
set(PROJECT_COMPANY "ON Semiconductor")
set(PROJECT_COPYRIGHT "Copyright (C) 2019 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_executable(${PROJECT_NAME}
    src/main.cpp
)

if(WIN32)
    configure_file(
        resources/main.rc.in
        resources/main.rc
        @ONLY
    )

    target_sources(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/resources/main.rc
    )
endif()


target_link_libraries(${PROJECT_NAME}
    Qt5::Core
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    #AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME ${PROJECT_NAME}
)
