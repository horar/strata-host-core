add_executable(DatabaseManager-sampleapp
    DatabaseManager-sampleapp.cpp
)

add_executable(Database-sampleapp
    couchbase-database-sampleapp.cpp
)

add_executable(TokenManager-sampleapp
    TokenManager-sampleapp.cpp
)

target_link_libraries(DatabaseManager-sampleapp
    PUBLIC
    Database
)

target_link_libraries(Database-sampleapp
    PUBLIC
    Database
)

target_link_libraries(TokenManager-sampleapp
    PUBLIC
    Database
)
