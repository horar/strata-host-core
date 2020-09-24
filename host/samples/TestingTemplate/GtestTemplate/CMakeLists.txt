add_executable(${PROJECT_NAME}-gtest
    main.cpp
    gtest-template-test.cpp
)

find_package(Qt5Test REQUIRED)

target_link_libraries(${PROJECT_NAME}-gtest
    PRIVATE Qt5::Test
    PRIVATE gtest::gtest
    PRIVATE ${PROJECT_NAME}
)

add_test(NAME ${PROJECT_NAME}-gtest
    COMMAND ${PROJECT_NAME}-gtest
)
