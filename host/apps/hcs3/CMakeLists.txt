
project(hcs3
    VERSION 0.0.0
    LANGUAGES CXX
)

message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Core Network
        REQUIRED
        )

set(HEADERS
    include/BoardsController.h
    include/HostControllerService.h
    include/PlatformBoard.h
    include/DownloadManager.h
    include/StorageManager.h
    include/LoggingAdapter.h
    src/logging/LoggingQtCategories.h
)

add_executable(${PROJECT_NAME}
    src/main.cpp
    src/HostControllerService.cpp
    src/BoardsController.cpp
    src/PlatformBoard.cpp
    src/Dispatcher.cpp
    src/HCS_Client.cpp
    src/ClientsController.cpp
    src/Database.cpp
    src/DownloadManager.cpp
    src/StorageManager.cpp
    src/PlatformDocument.cpp
    src/LoggingAdapter.cpp
    src/logging/LoggingQtCategories.cpp
    ${HEADERS}
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    )

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Network
    PlatformManager
    connector
    EventsMgr
    couchbase-lite-cpp
    QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME "hcs"
)

