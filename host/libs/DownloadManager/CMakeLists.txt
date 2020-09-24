project(DownloadManager
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Network
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/DownloadManager.cpp
    src/InternalDownloadRequest.cpp
    src/ReplyTimeout.cpp
    src/logging/LoggingQtCategories.cpp

    #AUTOMOC wont find header if it is in different directory
    include/DownloadManager.h
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::Network
    PUBLIC strata::QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)
