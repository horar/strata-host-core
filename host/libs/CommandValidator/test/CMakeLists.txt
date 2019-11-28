project(command-validator-test
    VERSION 0.1
    LANGUAGES CXX
)

add_executable(command-validator-test
command-validator-test.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE CommandValidator
    PRIVATE gtest::gtest
)
