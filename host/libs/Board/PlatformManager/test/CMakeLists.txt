project(PlatformManager-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

add_executable(${PROJECT_NAME}-test
    PlatformManagerDerivate.cpp
    PlatformManagerIntegrationTest.cpp
    PlatformManagerTest.cpp
    PlatformOperationsTest.cpp
    PlatformOperationsV2Test.cpp
    main.cpp
)

target_link_libraries(${PROJECT_NAME}-test
    PRIVATE Qt5::Test
    PRIVATE Platform
    PRIVATE PlatformManager
    PRIVATE CommandValidator
)

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)

