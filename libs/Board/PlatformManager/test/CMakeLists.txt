project(PlatformManager-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

add_executable(${PROJECT_NAME}-test
    PlatformManagerIntegrationTest.cpp
    PlatformManagerTest.cpp
    PlatformOperationsTest.cpp
    PlatformOperationsV2Test.cpp
    PlatformMessageTest.cpp
    main.cpp
)

target_link_libraries(${PROJECT_NAME}-test
    PRIVATE Qt5::Test
    PRIVATE Platform
    PRIVATE PlatformManager
    PRIVATE CommandValidator
    PRIVATE strata::base64
    PUBLIC rapidjson::rapidjson
)

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)

