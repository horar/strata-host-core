project(Database-sampleapp)

add_executable(Database-sampleapp
    CouchbaseDatabaseSampleApp.cpp
)

target_link_libraries(Database-sampleapp
    PRIVATE Database
    PUBLIC Qt5::Core
    PUBLIC Qt5::Network
)

set_target_properties(Database-sampleapp PROPERTIES
    AUTOMOC ON
)

if (APPLE)
    target_link_libraries(Database-sampleapp
        PRIVATE ${FOUNDATION_LIBRARY}
    )
endif()