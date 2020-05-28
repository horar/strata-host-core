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
    src/Database.cpp
    src/CouchbaseDatabase.cpp
    src/CouchbaseDocument.cpp
    # Logging Categories
    logging/LoggingQtCategories.h
    logging/LoggingQtCategories.cpp
)

target_include_directories(${PROJECT_NAME}
    PUBLIC
    src
    include
    logging
)

generate_app_version(GITTAG_PREFIX "cbdb" MACBUNDLE OFF)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::Network
    PUBLIC strata::Couchbase-Lite-C
    PUBLIC QtLogger
    rapidjson::rapidjson
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_subdirectory(sample-app)
    # add_subdirectory(test)
endif()