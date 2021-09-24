##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# QtMqtt
#

# to get Qt version for git checkout command
find_package(Qt5 COMPONENTS Core)
get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/qtmqtt" "${EXTERN_INSTALL_DIR_PATH}/qtmqtt" "${Qt5Core_VERSION_STRING}")
if(NOT LIB_INSTALLED)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/include)
    file(MAKE_DIRECTORY ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib)
    if(NOT WIN32)
        ExternalProject_Add(mqtt
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/qtmqtt
            EXCLUDE_FROM_ALL ON
            CONFIGURE_COMMAND ${QT_QMAKE_EXECUTABLE} "CONFIG+=debug_and_release build_all" ${SOURCE_DIR_EXTERN}/qtmqtt/qtmqtt.pro
            COMMAND ${GIT_EXECUTABLE} --git-dir=${SOURCE_DIR_EXTERN}/qtmqtt/.git checkout ${Qt5Core_VERSION_STRING}
            BUILD_COMMAND make # needed to do the build before copying the lib to 3p dir
            INSTALL_COMMAND

            COMMAND ${CMAKE_INSTALL_NAME_TOOL} -id <INSTALL_DIR>/lib/QtMqtt <BINARY_DIR>/lib/QtMqtt.framework/Versions/5/QtMqtt
            COMMAND ${CMAKE_INSTALL_NAME_TOOL} -id <INSTALL_DIR>/lib/QtMqtt_debug <BINARY_DIR>/lib/QtMqtt.framework/Versions/5/QtMqtt_debug
            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/lib/QtMqtt.framework/Headers <INSTALL_DIR>/include/QtMqtt
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/lib/QtMqtt.framework/Versions/5/QtMqtt <BINARY_DIR>/lib/QtMqtt.framework/Versions/5/QtMqtt_debug <INSTALL_DIR>/lib
        )
    else()

        # Search for perl path to add it to the path
        set(PERL_PATH  "")
        include(FindPerl)
        if( NOT PERL_FOUND )
            set(EXPECTED_PATH_TO_PERL "$ENV{PROGRAMFILES}\\Git\\usr\\bin")
            find_program(PERL_EXECUTABLE
                NAMES perl
                PATHS ${EXPECTED_PATH_TO_PERL}
            )
            if(PERL_EXECUTABLE)
                include(FindPerl)
            endif()
        endif()

        if(PERL_FOUND)
            get_filename_component(PERL_PATH "${PERL_EXECUTABLE}" PATH)

            # Create a cmd command to append Perl's path to the environment PATH
            string(REPLACE ";" "$<SEMICOLON>" MODIFIED_PATH "$ENV{PATH}")
            separate_arguments(APPEND_PERL_TO_PATH WINDOWS_COMMAND "SET PATH=${MODIFIED_PATH}$<SEMICOLON>${PERL_PATH}")
        else()
            message(FATAL_ERROR "Perl NOT found. Please make sure that Perl is installed and added to the path.")
        endif()

        ExternalProject_Add(mqtt
            INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}
            SOURCE_DIR ${SOURCE_DIR_EXTERN}/qtmqtt
            EXCLUDE_FROM_ALL ON
            CONFIGURE_COMMAND ${QT_QMAKE_EXECUTABLE} ${SOURCE_DIR_EXTERN}/qtmqtt/qtmqtt.pro -spec win32-msvc
            COMMAND ${GIT_EXECUTABLE} --git-dir=${SOURCE_DIR_EXTERN}/qtmqtt/.git checkout ${Qt5Core_VERSION_STRING}
            COMMAND ${APPEND_PERL_TO_PATH}
            BUILD_COMMAND
            INSTALL_COMMAND

            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/src/mqtt/ <INSTALL_DIR>/include/QtMqtt
            COMMAND ${CMAKE_COMMAND} -E copy_directory <BINARY_DIR>/bin <INSTALL_DIR>/bin
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/bin/Qt5Mqtt.dll <BINARY_DIR>/bin/Qt5Mqttd.dll ${CMAKE_BINARY_DIR}/bin
            COMMAND ${CMAKE_COMMAND} -E copy_if_different <BINARY_DIR>/lib/Qt5Mqtt.lib <BINARY_DIR>/lib/Qt5Mqttd.lib <BINARY_DIR>/lib/Qt5Mqttd.pdb <INSTALL_DIR>/lib
        )
    endif()
else()
    if(WIN32)
        file(COPY ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/bin/Qt5Mqttd.dll
        ${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/bin/Qt5Mqtt.dll
        DESTINATION ${CMAKE_BINARY_DIR}/bin)
    endif()
endif()

add_library(mqtt::mqtt STATIC IMPORTED GLOBAL)

if(NOT WIN32)
    set_target_properties(mqtt::mqtt PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/include"
        IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib/QtMqtt"
        IMPORTED_LOCATION_DEBUG "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib/QtMqtt_debug"
    )
else()
    set_target_properties(mqtt::mqtt PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/include"
        IMPORTED_LOCATION "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib/Qt5Mqtt.lib"
        IMPORTED_LOCATION_DEBUG "${EXTERN_INSTALL_DIR_PATH}/qtmqtt-${GIT_HASH}/lib/Qt5Mqttd.lib"
    )
endif()

add_dependencies(mqtt::mqtt DEPENDS mqtt)
