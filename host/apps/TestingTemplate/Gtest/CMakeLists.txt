add_executable(${PROJECT_NAME}-gtest
    main.cpp
    gtest-template-test.cpp
)

target_link_libraries(${PROJECT_NAME}-gtest
    PRIVATE gtest::gtest
    PRIVATE test-template
)

add_test(NAME ${PROJECT_NAME}-gtest
    COMMAND ${PROJECT_NAME}-gtest
)
