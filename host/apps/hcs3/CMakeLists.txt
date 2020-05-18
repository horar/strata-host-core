project(HostControllerService
    DESCRIPTION "Host Controller Service"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/on.ico)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2020 ${PROJECT_COMPANY}")


set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Core Network Concurrent
        REQUIRED
)

add_executable(${PROJECT_NAME} WIN32
    src/main.cpp
)

target_link_libraries(${PROJECT_NAME}
    ${PROJECT_NAME}Lib
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME hcs
)

add_library(${PROJECT_NAME}Lib STATIC
    src/HostControllerService.cpp
    src/BoardManagerWrapper.cpp
    src/Dispatcher.cpp
    src/HCS_Client.cpp
    src/ClientsController.cpp
    src/Database.cpp
    src/DownloadManager.cpp
    src/StorageManager.cpp
    src/StorageInfo.cpp
    src/PlatformDocument.cpp
    src/LoggingAdapter.cpp

    src/logging/LoggingQtCategories.cpp
)

generate_app_version(GITTAG_PREFIX "hcs3_" MACBUNDLE OFF)

set_target_properties(${PROJECT_NAME}Lib PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"
)

target_link_libraries(${PROJECT_NAME}Lib PUBLIC
    Qt5::Core
    Qt5::Network
    Qt5::Concurrent

    BoardManager
    connector
    EventsMgr
    strata::CouchbaseLiteCPP
    QtLogger
)

target_include_directories(${PROJECT_NAME}Lib
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src
    PRIVATE $<IF:$<CONFIG:Release>, ${CMAKE_CURRENT_SOURCE_DIR}/src/release, ${CMAKE_CURRENT_SOURCE_DIR}/src/debug>
)
