project(BoardManager-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

add_executable(${PROJECT_NAME}-test
    BoardManagerDerivate.cpp
    BoardManagerIntegrationTest.cpp
    BoardManagerTest.cpp
    DeviceMock.cpp
    DeviceOperationsTest.cpp
    CommandResponseMock.cpp
    main.cpp
)

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

