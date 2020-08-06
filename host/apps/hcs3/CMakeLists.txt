project(HostControllerService
    DESCRIPTION "Strata Host Controller Service"
    LANGUAGES CXX
)

set(PROJECT_BUNDLE_ID com.onsemi.strata.hcs)
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
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<IF:$<CONFIG:OTA>,packages/${PROJECT_BUNDLE_ID}/data,bin>
)

qt5_generate_repc(NODE_RO_SRCS ./src/HostControllerService.rep SOURCE)

add_library(${PROJECT_NAME}Lib STATIC
    src/HostControllerService.cpp
    src/BoardController.cpp
    src/Dispatcher.cpp
    src/Client.cpp
    src/ClientsController.cpp
    src/Database.cpp
    src/StorageManager.cpp
    src/StorageInfo.cpp
    src/PlatformDocument.cpp
    src/FirmwareUpdateController.cpp
    src/FirmwareUpdater.cpp

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
    FlasherConnector
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

# deploy desired config file into side-by-side to compiled binary
set(HCS_CONFIG_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/files/conf)

if(NOT APPS_CORESW_HCS_CONFIG)
    set(APPS_CORESW_HCS_CONFIG hcs_qa.config CACHE STRING "Desired HCS configuration file." FORCE)
    message(STATUS "Defaulting 'APPS_CORESW_HCS_CONFIG' to ${APPS_CORESW_HCS_CONFIG}.")
endif()
file(GLOB APPS_CORESW_HCS_CONFIG_CHOICES
    RELATIVE ${HCS_CONFIG_LOCATION}
    ${HCS_CONFIG_LOCATION}/*.config
)
set_property(CACHE APPS_CORESW_HCS_CONFIG PROPERTY STRINGS ${APPS_CORESW_HCS_CONFIG_CHOICES})
if(NOT APPS_CORESW_HCS_CONFIG IN_LIST APPS_CORESW_HCS_CONFIG_CHOICES)
    message(FATAL_ERROR "Specify 'APPS_CORESW_HCS_CONFIG'. Must be one of ${APPS_CORESW_HCS_CONFIG_CHOICES}")
endif()

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${HCS_CONFIG_LOCATION}/${APPS_CORESW_HCS_CONFIG}
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/hcs.config
    COMMENT "Deploying 'hcs.config'..."
    VERBATIM
)
