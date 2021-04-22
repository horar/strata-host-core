project(HostControllerService
    DESCRIPTION "Strata Host Controller Service"
    LANGUAGES CXX
)

set(PROJECT_BUNDLE_ID com.onsemi.strata.hcs)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2021 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Core Concurrent RemoteObjects
        REQUIRED
)

add_executable(${PROJECT_NAME} WIN32
    src/main.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE ${PROJECT_NAME}Lib
)

if(APPLE)
    set(OPENSSL_ROOT_DIR ${SSL_LIB_PATH_MACOS})
    find_package(OpenSSL 1.1 REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        OpenSSL::SSL
        OpenSSL::Crypto
    )
endif()

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

generate_app_version(GITTAG_PREFIX "hcs_" MACBUNDLE OFF)
generate_app_build_timestamp()

set(HCS_CREDENTIALS_LOCATION ${CMAKE_SOURCE_DIR}/internal/assets/config/hcs/credentials)

if(NOT APPS_CORESW_HCS_CREDENTIALS)
    set(APPS_CORESW_HCS_CREDENTIALS qa.json CACHE STRING "Desired HCS configuration file with credentials." FORCE)
    message(STATUS "Defaulting 'APPS_CORESW_HCS_CREDENTIALS' to ${APPS_CORESW_HCS_CREDENTIALS}.")
endif()
file(GLOB HCS_CREDENTIALS_LOCATION_CHOICES
    RELATIVE ${HCS_CREDENTIALS_LOCATION}
    ${HCS_CREDENTIALS_LOCATION}/*.json
)
set_property(CACHE APPS_CORESW_HCS_CREDENTIALS PROPERTY STRINGS ${HCS_CREDENTIALS_LOCATION_CHOICES})

file(READ ${CMAKE_SOURCE_DIR}/internal/assets/config/hcs/credentials/${APPS_CORESW_HCS_CREDENTIALS} JSON_CREDENTIALS)
generate_replicator_credentials(JSON_FILE ${JSON_CREDENTIALS})

set_target_properties(${PROJECT_NAME}Lib PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"
)

target_link_libraries(${PROJECT_NAME}Lib PUBLIC
    Qt5::Core
    Qt5::Concurrent
    Qt5::RemoteObjects

    strata::PlatformManager
    strata::FlasherConnector
    strata::connector
    strata::EventsMgr
    strata::DownloadManager
    strata::Database
    strata::QtLogger
    strata::CbLogger
    rapidjson::rapidjson
)

target_include_directories(${PROJECT_NAME}Lib
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src
    PRIVATE $<IF:$<OR:$<CONFIG:Release>,$<CONFIG:OTA>>, ${CMAKE_CURRENT_SOURCE_DIR}/src/release, ${CMAKE_CURRENT_SOURCE_DIR}/src/debug>
)

if(WIN32)
    get_target_property(QT_LIBRARY_DIR Qt5::Core LOCATION)
    get_filename_component(QT_LIBRARY_DIR ${QT_LIBRARY_DIR} PATH)
    get_filename_component(QT_SSL_LIBRARY_DIR "${QT_LIBRARY_DIR}/../../../Tools/OpenSSL/Win_x64//bin" ABSOLUTE)
    if(EXISTS ${QT_SSL_LIBRARY_DIR})
        message(STATUS "OpenSSL DLL's will be copyed from ${QT_SSL_LIBRARY_DIR}")
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                ${QT_SSL_LIBRARY_DIR}/libcrypto-1_1-x64.dll
                $<TARGET_FILE_DIR:${PROJECT_NAME}>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                ${QT_SSL_LIBRARY_DIR}/libssl-1_1-x64.dll
                $<TARGET_FILE_DIR:${PROJECT_NAME}>
            COMMENT "Deploying dependant 3rd party Qt OpenSSL libraries..."
            VERBATIM
        )
    else()
        message(WARNING "Please install OpenSSL coming with your Qt installer (can't find OpenSSL DLL's in '${QT_SSL_LIBRARY_DIR}'")
    endif()
endif()


# deploy desired config file into side-by-side to compiled binary
set(HCS_CONFIG_LOCATION ${CMAKE_SOURCE_DIR}/internal/assets/config/hcs)

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

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)
