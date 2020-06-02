project(BoardManager-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

enable_testing(true)

file(GLOB sources "*.cpp")
add_executable(${PROJECT_NAME}-test ${sources})

target_link_libraries(${PROJECT_NAME}-test
    PRIVATE Qt5::Test
    PRIVATE BoardManager
    PRIVATE Device
    PRIVATE DeviceOperations
    PRIVATE CommandValidator
)

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)

