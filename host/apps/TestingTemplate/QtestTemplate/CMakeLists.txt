set(CMAKE_AUTOMOC ON)

find_package(Qt5Test REQUIRED)

add_executable(${PROJECT_NAME}-qtest
    main.cpp
    qtest-template-test.cpp
)

target_link_libraries(${PROJECT_NAME}-qtest
    PRIVATE Qt5::Test
    PRIVATE test-template
)

add_test(NAME ${PROJECT_NAME}-qtest
   COMMAND ${PROJECT_NAME}-qtest
)
