set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/tests")

add_executable(database-test
    main.cpp
    couchbase-database-test.cpp
)

target_link_libraries(database-test
    PRIVATE Database
    PRIVATE gtest::gtest
)

add_test(NAME database-test
    COMMAND database-test
)
