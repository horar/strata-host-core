project(PlatformInterface
    VERSION 1.0.0
    LANGUAGES CXX
)

message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 5.10
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/CoreInterface.cpp
    # This is to let CMake know to run moc preprocessor on header files
    # with Q_OBJECT macro.
    include/PlatformInterface/core/CoreInterface.h
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core

    PUBLIC HostControllerClient
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/PlatformInterface
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    AUTOMOC ON
)

target_compile_options(${PROJECT_NAME}
    PRIVATE $<$<CXX_COMPILER_ID:AppleClang>:-Wall -Wextra>
)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE QT_DEPRECATED_WARNINGS
    PRIVATE QT_DISABLE_DEPRECATED_BEFORE=0x060000
)
