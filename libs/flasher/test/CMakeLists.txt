project(Flasher-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

add_executable(${PROJECT_NAME}-test
    FlasherTest.cpp
    FlasherTestConstants.h
    main.cpp
)

target_link_libraries(${PROJECT_NAME}-test
    PRIVATE Qt5::Test
    PRIVATE Flasher
    PRIVATE strata::base64
    PRIVATE strata::crc16
)

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)

if(BUILD_TESTING)
    add_compile_definitions(BUILD_TESTING)
endif()

