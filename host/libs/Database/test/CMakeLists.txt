add_executable(couchbase-database-test
    main.cpp
    couchbase-database-test.cpp
)

target_link_libraries(couchbase-database-test
    PRIVATE Database
    PRIVATE gtest::gtest
)

add_test(NAME couchbase-database-test
    COMMAND couchbase-database-test
)