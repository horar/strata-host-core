project(HostControllerService
    DESCRIPTION "Host Controller Service"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/on.ico)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2019 ${PROJECT_COMPANY}")


set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Core Network
        REQUIRED
)

add_executable(${PROJECT_NAME} WIN32
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

generate_version(GITTAG_PREFIX "hcs3_" MACBUNDLE OFF)

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

    OUTPUT_NAME hcs
)
