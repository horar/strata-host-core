set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/tests")

add_executable(${PROJECT_NAME}-test
    main.cpp
    SGUtilsCpp-test.cpp
)

target_link_libraries(${PROJECT_NAME}-test
    PRIVATE SGUtilsCpp
    PRIVATE gtest::gtest
)

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)
