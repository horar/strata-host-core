add_executable(test-${PROJECT_NAME}
    main.cpp
    command-validator-test.cpp
)

target_link_libraries(test-${PROJECT_NAME}
    PRIVATE strata::CommandValidator
    PRIVATE gtest::gtest
)

add_test(NAME test-${PROJECT_NAME}
    COMMAND test-${PROJECT_NAME}
)
