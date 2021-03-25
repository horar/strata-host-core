project(platform-identification-test
    VERSION 0.0.1
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME}
   src/main.cpp
   src/PlatformIdentificationTest.cpp
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Platform
    PlatformManager
    SGJLinkConnector
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES AUTOMOC ON
)
