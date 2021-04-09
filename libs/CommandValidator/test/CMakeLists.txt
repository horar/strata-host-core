add_executable(${PROJECT_NAME}-test
    main.cpp
    command-validator-test.cpp
)

target_link_libraries(${PROJECT_NAME}-test
    PRIVATE CommandValidator
    PRIVATE gtest::gtest
)

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)
