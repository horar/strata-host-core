##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# Strata applications
#
option(APPS_CORESW "Build Strata applications" ON)
add_feature_info(APPS_CORESW APPS_CORESW "Build Strata applications")

cmake_dependent_option(APPS_CORESW_HCS "Build 'hcs' service" ON
                            "APPS_CORESW" OFF)
add_feature_info(APPS_CORESW_HCS APPS_CORESW_HCS "Host controller service")

if(NOT MINGW)
    cmake_dependent_option(APPS_CORESW_SDS "Build 'Strata Developer Studio' app" ON
                            "APPS_CORESW" OFF)
    add_feature_info(APPS_CORESW_SDS APPS_CORESW_SDS "Strata Developer Studio")

    # DevStudio plugins
    include(AddDevStudioPLugin)
    cmake_dependent_option(APPS_CORESW_SDS_PLUGIN_DEBUGBAR "Build DevStudio 'debugbar' plugin" ON
        "APPS_CORESW_SDS" OFF)
    add_feature_info(APPS_CORESW_SDS_PLUGIN_DEBUGBAR APPS_CORESW_SDS_PLUGIN_DEBUGBAR "DevStudio 'debugbar' plugin")

    cmake_dependent_option(APPS_CORESW_SDS_PLUGIN_CVC "Build DevStudio 'CVC' plugin" ON
        "APPS_CORESW_SDS" OFF)
    add_feature_info(APPS_CORESW_SDS_PLUGIN_CVC APPS_CORESW_SDS_PLUGIN_CVC "DevStudio 'Control View Creator' plugin")
else()
    message(WARNING "Strata Developer Studio is not supported in MinGW development environment!")
endif()


#
# Strata toolbox/development utilities
#
option(APPS_TOOLBOX "Build Strata Toolbox/utilities" ON)
add_feature_info(APPS_TOOLBOX APPS_TOOLBOX "Build Strata Toolbox/utilities")

cmake_dependent_option(APPS_TOOLBOX_FLASHER "Build 'Flasher' app" ON
                        "APPS_TOOLBOX" OFF)
add_feature_info(APPS_TOOLBOX_FLASHER APPS_TOOLBOX_FLASHER "Platform flasher cli")
cmake_dependent_option(APPS_TOOLBOX_SCI "Build 'Serial Console Interface'" ON
                        "APPS_TOOLBOX" OFF)
add_feature_info(APPS_TOOLBOX_SCI APPS_TOOLBOX_SCI "Serial Console Interface")
cmake_dependent_option(APPS_TOOLBOX_PRT "Build 'Platform Registration Tool'" ON
                        "APPS_TOOLBOX" OFF)
add_feature_info(APPS_TOOLBOX_PRT APPS_TOOLBOX_PRT "Platform Registration Tool")
cmake_dependent_option(APPS_TOOLBOX_CBB "Build 'CouchbaseBrowser'" ON
                        "APPS_TOOLBOX" OFF)
add_feature_info(APPS_TOOLBOX_CBB APPS_TOOLBOX_CBB "CouchbaseBrowser")
cmake_dependent_option(APPS_TOOLBOX_CDC "Build 'Command Doc Creator'" ON
                        "APPS_TOOLBOX" OFF)
add_feature_info(APPS_TOOLBOX_CDC APPS_TOOLBOX_CDC "Command Doc Creator")
cmake_dependent_option(APPS_TOOLBOX_LV "Build 'LogViewer'" ON
                        "APPS_TOOLBOX" OFF)
add_feature_info(APPS_TOOLBOX_LV APPS_TOOLBOX_LV "LogViewer")
cmake_dependent_option(APPS_TOOLBOX_WG "Build 'Widget Gallery'" ON
                        "APPS_TOOLBOX" OFF)
add_feature_info(APPS_TOOLBOX_WG APPS_TOOLBOX_WG "Widget Gallery")
cmake_dependent_option(APPS_TOOLBOX_LCU "Build 'LoggingConfigurationUtility'" ON
                        "APPS_TOOLBOX" OFF)
add_feature_info(APPS_TOOLBOX_LCU APPS_TOOLBOX_LCU "Logging Configuration Utility")

if(APPS_CORESW_HCS)
    add_subdirectory(hcs3)
endif()

if(APPS_CORESW_SDS AND NOT MINGW)
    add_subdirectory(DeveloperStudio)
else()
    message(STATUS "Cleaning plugins (DevStudio is disabled)")
    file(GLOB SDS_PLUGIN_LIST ${CMAKE_PLUGINS_OUTPUT_DIRECTORY}/sds-*.rcc)
    if(SDS_PLUGIN_LIST)
        file(REMOVE ${SDS_PLUGIN_LIST})
    endif()
endif()


if(APPS_TOOLBOX_FLASHER)
    add_subdirectory(Flasher)
endif()

if (APPS_TOOLBOX_SCI)
    add_subdirectory(SerialConsoleInterface)
endif()

if (APPS_TOOLBOX_PRT)
    add_subdirectory(PlatformRegistrationTool)
endif()

if (APPS_TOOLBOX_CBB)
    add_subdirectory(CouchbaseBrowser)
endif()

if (APPS_TOOLBOX_CDC)
    add_subdirectory(CommandDocCreator)
endif()

if (APPS_TOOLBOX_LV)
    add_subdirectory(LogViewer)
endif()

if (APPS_TOOLBOX_WG)
    add_subdirectory(WidgetGallery)
endif()

if (APPS_TOOLBOX_LCU)
    add_subdirectory(LoggingConfigurationUtility)
endif()
