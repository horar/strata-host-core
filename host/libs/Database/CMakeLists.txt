project(Database
    VERSION 1.0.0
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Network
    REQUIRED
)

add_library(${PROJECT_NAME}
    # Database
    include/Database.h
    include/CouchbaseDatabase.h
    include/CouchbaseDocument.h
    include/DatabaseManager.h
    include/DatabaseAccess.h

    src/Database.cpp
    src/CouchbaseDatabase.cpp
    src/CouchbaseDocument.cpp
    src/DatabaseManager.cpp
    src/DatabaseAccess.cpp

    # Logging Categories
    logging/LoggingQtCategories.h
    logging/LoggingQtCategories.cpp
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC include
    PRIVATE src
    PRIVATE logging
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::Network
    PUBLIC strata::Couchbase-Lite-C
    PUBLIC strata::QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
)

if(BUILD_EXAMPLES)
    add_subdirectory(sample-app)
endif()

if(BUILD_TESTING)
    add_subdirectory(test)
endif()

add_subdirectory(sample-app)
