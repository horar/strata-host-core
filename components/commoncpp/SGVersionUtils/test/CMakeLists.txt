add_executable(test-${PROJECT_NAME}
    main.cpp
    SGVersionUtils-test.cpp
)

target_link_libraries(test-${PROJECT_NAME}
    PRIVATE SGVersionUtils
    PRIVATE gtest::gtest
)

add_test(NAME test-${PROJECT_NAME}
    COMMAND test-${PROJECT_NAME}
)
