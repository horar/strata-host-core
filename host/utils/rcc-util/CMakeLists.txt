project(rcc-util
    LANGUAGES CXX
)

set(PROJECT_COMPANY "ON Semiconductor")
set(PROJECT_COPYRIGHT "Copyright (C) 2019-2020 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_executable(${PROJECT_NAME}
    src/main.cpp
)

generate_app_version(GITTAG_PREFIX "rccutil_" MACBUNDLE OFF)



target_link_libraries(${PROJECT_NAME}
    Qt5::Core
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    #AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME ${PROJECT_NAME}
)
