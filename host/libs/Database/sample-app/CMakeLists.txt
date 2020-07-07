project(Database-sampleapp
    LANGUAGES CXX
)

add_executable(Database-sampleapp
    CouchbaseDatabaseSampleApp.cpp
)

target_link_libraries(Database-sampleapp
    PUBLIC
    Database
)

if (APPLE)
    target_link_libraries(Database-sampleapp
        PRIVATE ${FOUNDATION_LIBRARY}
    )
endif()
