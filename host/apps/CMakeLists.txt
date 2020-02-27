#
# Strta applications
#
option(APPS_CORE "Build Strata applications" ON)
add_feature_info(APPS_CORE APPS_CORE "Build Strata applications")

cmake_dependent_option(APPS_CORE_HCS "Build 'hcs' service" ON
                            "APPS_CORE" OFF)
add_feature_info(APPS_CORE_HCS APPS_CORE_HCS "Host controller service")

cmake_dependent_option(APPS_CORE_HCS_V3 "Build 'hcs' service version 3" ON
                            "APPS_CORE;APPS_CORE_HCS" OFF)
add_feature_info(APPS_CORE_HCS_V3 APPS_CORE_HCS_V3 "Host controller service - version 3")

if(NOT MINGW)
    cmake_dependent_option(APPS_CORE_DEVSTUDIO "Build 'Strata Developer Studio' app" ON
                            "APPS_CORE;APPS_CORE_HCS" OFF)
    add_feature_info(APPS_CORE_DEVSTUDIO APPS_CORE_DEVSTUDIO "Strata Developer Studio")
else()
    message(WARNING "Strata Developer Studio is not supported in MinGW development environment!")
endif()


#
# Strta development utilities
#
option(APPS_COREUTILS "Build Strata platform utilities" ON)
add_feature_info(APPS_COREUTILS APPS_COREUTILS "Build Strata platform utilities")

cmake_dependent_option(APPS_COREUTILS_FLASHER "Build 'Flasher' app" ON
                        "APPS_COREUTILS" OFF)
add_feature_info(APPS_COREUTILS_FLASHER APPS_COREUTILS_FLASHER "Platform flasher cli")
cmake_dependent_option(APPS_COREUTILS_SCI "Build 'Serial Console Interface'" ON
                        "APPS_COREUTILS" OFF)
add_feature_info(APPS_COREUTILS_SCI APPS_COREUTILS_SCI "Serial Console Interface")
cmake_dependent_option(APPS_COREUTILS_PRT "Build 'Platform Registration Tool'" ON
                        "APPS_COREUTILS" OFF)
add_feature_info(APPS_COREUTILS_PRT APPS_COREUTILS_PRT "Platform Registration Tool")
cmake_dependent_option(APPS_COREUTILS_CBB "Build 'CouchbaseBrowser'" ON
                        "APPS_COREUTILS" OFF)
add_feature_info(APPS_COREUTILS_CBB APPS_COREUTILS_CBB "CouchbaseBrowser")
cmake_dependent_option(APPS_COREUTILS_CDC "Build 'Command Doc Creator'" ON
                        "APPS_COREUTILS" OFF)
add_feature_info(APPS_COREUTILS_CDC APPS_COREUTILS_CDC "Command Doc Creator")
cmake_dependent_option(APPS_COREUTILS_LV "Build 'LogViewer'" ON
                        "APPS_COREUTILS" OFF)
add_feature_info(APPS_COREUTILS_LV APPS_COREUTILS_LV "LogViewer")
cmake_dependent_option(APPS_COREUTILS_WG "Build 'Widget Gallery'" ON
                        "APPS_COREUTILS" OFF)
add_feature_info(APPS_COREUTILS_WG APPS_COREUTILS_WG "Widget Gallery")

if(APPS_CORE_HCS)
    if(APPS_CORE_HCS_V3)
        add_subdirectory(hcs3)
    else()
        add_subdirectory(hcs2)
    endif()
endif()

if(APPS_CORE_DEVSTUDIO AND NOT MINGW)
    add_subdirectory(DeveloperStudio)
endif()


if(APPS_COREUTILS_FLASHER)
    add_subdirectory(Flasher)
endif()

if (APPS_COREUTILS_SCI)
    add_subdirectory(SerialConsoleInterface)
endif()

if (APPS_COREUTILS_PRT)
    add_subdirectory(PlatformRegistrationTool)
endif()

if (APPS_COREUTILS_CBB)
    add_subdirectory(CouchbaseBrowser)
endif()

if (APPS_COREUTILS_CDC)
    add_subdirectory(CommandDocCreator)
endif()

if (APPS_COREUTILS_LV)
    add_subdirectory(LogViewer)
endif()

if (APPS_COREUTILS_WG)
    add_subdirectory(WidgetGallery)
endif()
