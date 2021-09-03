add_executable(test-database
    main.cpp
    couchbase-database-test.cpp
)

target_link_libraries(test-database
    PRIVATE Database
    PRIVATE gtest::gtest
)

add_test(NAME test-database
    COMMAND test-database
)
