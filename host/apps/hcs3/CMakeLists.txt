project(hcs
    VERSION 3.0.0.0
    DESCRIPTION "Host Controller Service"
    LANGUAGES CXX
)

message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")

set(PROJECT_COMPANY "ON Semiconductor")
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2019 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Core Network
        REQUIRED
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
    src/DownloadGroup.cpp
    src/LoggingAdapter.cpp

    src/logging/LoggingQtCategories.cpp
)

if(WIN32)
    configure_file(
        resources/main.rc.in
        resources/main.rc
        @ONLY
    )

    target_sources(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/resources/main.rc
    )
endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Network

    PlatformManager
    connector
    EventsMgr
    strata::CouchbaseLiteCPP
    QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME "hcs"
)

