##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(PlatformRegistrationTool
    DESCRIPTION "Platform Registration Tool"
    LANGUAGES CXX
)

set(PROJECT_WIN32_ICO resources/icons/app/prt-logo.ico)
set(PROJECT_MACOS_ICNS prt-logo.icns)
set(PROJECT_BUNDLE_ID com.onsemi.strata.prt)
set(PROJECT_COPYRIGHT "Copyright (C) 2018-2022 ${PROJECT_COMPANY}")


set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Qml
    REQUIRED
)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE)
target_sources(${PROJECT_NAME} PRIVATE
    main.cpp
    PrtModel.cpp
    RestClient.cpp
    Authenticator.cpp

    images/images.qrc
    qml.qrc

    logging/LoggingQtCategories.cpp
    logging/qml/tech/strata/logger/qml.qrc
)

set(${PROJECT_NAME}_ENABLED_PLUGINS "")
add_qml_debug_plugin_to_version(PROJ_NAME ${PROJECT_NAME} PLUGIN_NAME "qmldebug")

generate_app_version(GITTAG_PREFIX "prt_" MACBUNDLE ON)
generate_app_build_timestamp()

if(APPLE)
    find_library(IOKIT_LIB IOKit REQUIRED)
    if (NOT IOKIT_LIB)
        message(FATAL_ERROR "IOKit framework not found")
    endif()
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()

    target_link_libraries(${PROJECT_NAME}
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
    )

    target_sources(${PROJECT_NAME} PRIVATE
        resources/icons/app/prt-logo.icns
    )
    set_source_files_properties(
        resources/icons/app/prt-logo.icns
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )
endif()

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Qml
    Qt5::Quick

    strata::Platform
    strata::PlatformManager
    strata::FlasherConnector
    strata::DownloadManager
    strata::QtLogger
    strata::SGUtilsCpp
    strata::SGVersionUtils
)

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    #AUTORCC_OPTIONS "--compress;9"

    OUTPUT_NAME "${PROJECT_DESCRIPTION}"
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

set(PRT_CONFIG_PATHS_LIST)

if(IS_DIRECTORY "${STRATA_HOST_CORE_INTERNAL_PATH}/assets/config/prt")
    list(APPEND PRT_CONFIG_PATHS_LIST ${STRATA_HOST_CORE_INTERNAL_PATH}/assets/config/prt)
endif()
list(APPEND PRT_CONFIG_PATHS_LIST ${CMAKE_HOME_DIRECTORY}/assets/config/prt)

find_all_config_files("${PRT_CONFIG_PATHS_LIST}" "*.ini" APPS_TOOLBOX_PRT_CONFIG_CHOICES)

if(NOT APPS_TOOLBOX_PRT_CONFIG)
    if("qa.ini" IN_LIST APPS_TOOLBOX_PRT_CONFIG_CHOICES)
        set(APPS_TOOLBOX_PRT_CONFIG "qa.ini" CACHE STRING "Desired PRT configuration file." FORCE)
    else()
        set(APPS_TOOLBOX_PRT_CONFIG "template.ini" CACHE STRING "Desired PRT configuration file." FORCE)
    endif()
endif()

set_property(CACHE APPS_TOOLBOX_PRT_CONFIG PROPERTY STRINGS ${APPS_TOOLBOX_PRT_CONFIG_CHOICES})
if(NOT APPS_TOOLBOX_PRT_CONFIG IN_LIST APPS_TOOLBOX_PRT_CONFIG_CHOICES)
    message(FATAL_ERROR "Specify 'APPS_TOOLBOX_PRT_CONFIG'. Must be one of ${APPS_TOOLBOX_PRT_CONFIG_CHOICES}")
endif()

deploy_config_file("${PRT_CONFIG_PATHS_LIST}" ${APPS_TOOLBOX_PRT_CONFIG} "prt.ini")

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
    $<$<CONFIG:Debug>:QT_QML_DEBUG>
)

add_qml_import_path(PATH "${CMAKE_CURRENT_SOURCE_DIR}")
