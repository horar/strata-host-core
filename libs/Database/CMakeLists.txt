##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
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
    include/Database/DatabaseLib.h
    include/Database/DatabaseManager.h
    include/Database/DatabaseAccess.h
    include/Database/CouchbaseDocument.h

    src/CouchbaseDatabase.h
    src/DatabaseLib.cpp
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

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
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
