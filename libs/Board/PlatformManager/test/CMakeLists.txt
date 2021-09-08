project(PlatformManager-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

set(SOURCE_FILES
    PlatformManagerIntegrationTest.cpp
    PlatformManagerTest.cpp
    PlatformOperationsTest.cpp
    PlatformOperationsV2Test.cpp
    PlatformMessageTest.cpp
    PlatformErrorsTest.cpp
)

foreach(SOURCE_PATH ${SOURCE_FILES})

    get_filename_component(EXECUTABLE_NAME ${SOURCE_PATH} NAME_WE)

    string(REPLACE "Test" "" EXECUTABLE_NAME ${EXECUTABLE_NAME})
    string(PREPEND EXECUTABLE_NAME "test-")

    add_executable(${EXECUTABLE_NAME} ${SOURCE_PATH})

    target_link_libraries(${EXECUTABLE_NAME}
        PRIVATE Qt5::Test
        PRIVATE strata::Platform
        PRIVATE strata::PlatformManager
        PRIVATE strata::CommandValidator
        PRIVATE strata::base64
    )

    add_test(NAME ${EXECUTABLE_NAME}
        COMMAND ${EXECUTABLE_NAME}
    )

endforeach(SOURCE_PATH ${SOURCE_FILES})
