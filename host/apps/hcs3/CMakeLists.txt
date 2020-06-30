project(HostControllerService
    DESCRIPTION "Strata Host Controller Service"
    LANGUAGES CXX
)

set(PROJECT_COPYRIGHT "Copyright (C) 2018-2020 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Core Concurrent RemoteObjects
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

qt5_generate_repc(NODE_RO_SRCS ./src/HostControllerService.rep SOURCE)

add_library(${PROJECT_NAME}Lib STATIC
    src/HostControllerService.cpp
    src/BoardController.cpp
    src/Dispatcher.cpp
    src/HCS_Client.cpp
    src/ClientsController.cpp
    src/Database.cpp
    src/StorageManager.cpp
    src/StorageInfo.cpp
    src/PlatformDocument.cpp
    src/LoggingAdapter.cpp

    src/RunGuard.cpp

    src/logging/LoggingQtCategories.cpp

    src/HostControllerServiceNode.cpp
    ${NODE_RO_SRCS}
)
if(NOT WIN32)
    target_sources(${PROJECT_NAME}Lib PRIVATE
        src/unix/SignalHandlers.cpp
    )
endif()

generate_app_version(GITTAG_PREFIX "hcs3_" MACBUNDLE OFF)
generate_app_build_timestamp()

set_target_properties(${PROJECT_NAME}Lib PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"
)

target_link_libraries(${PROJECT_NAME}Lib PUBLIC
    Qt5::Core
    Qt5::Concurrent
    Qt5::RemoteObjects

    BoardManager
    connector
    EventsMgr
    DownloadManager
    strata::CouchbaseLiteCPP
    QtLogger
    CbLogger
)

target_include_directories(${PROJECT_NAME}Lib
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src
    PRIVATE $<IF:$<CONFIG:Release>, ${CMAKE_CURRENT_SOURCE_DIR}/src/release, ${CMAKE_CURRENT_SOURCE_DIR}/src/debug>
)
