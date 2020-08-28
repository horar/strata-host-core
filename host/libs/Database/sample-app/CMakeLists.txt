project(database-sampleapp
    LANGUAGES CXX
)

add_executable(database-sampleapp
    couchbase-database-sampleapp.cpp
)

target_link_libraries(database-sampleapp
    PUBLIC
    Database
)

if (APPLE)
    target_link_libraries(database-sampleapp
        PRIVATE ${FOUNDATION_LIBRARY}
    )
endif()
