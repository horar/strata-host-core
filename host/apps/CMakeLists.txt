include(CMakeDependentOption)

option(APPS_HCS2 "Build 'hcs2' service" ON)
add_feature_info(APPS_HCS2 APPS_HCS2 "Host controller service")
option(APPS_FLASHER "Build 'Flasher' app" ON)
add_feature_info(APPS_FLASHER APPS_FLASHER "Platform flasher cli")
if(NOT MINGW)
    cmake_dependent_option(APPS_DEVSTUDIO "Build 'Strata Developer Studio' app" ON
                           "APPS_HCS2" OFF)
    add_feature_info(APPS_DEVSTUDIO APPS_DEVSTUDIO "Strata Developer Studio")
else()
    message(WARNING "Strata Developer Studio is not supported in MinGW development environment!")
endif()
option(APPS_SCI "Build 'Serial Console Interface'" ON)
add_feature_info(APPS_SCI APPS_SCI "Serial Console Interface")
option(APPS_PRT "Build 'Platform Registration Tool'" ON)
add_feature_info(APPS_PRT APPS_PRT "Platform Registration Tool")

if(APPS_HCS2)
    add_subdirectory(hcs2)
endif()

if(APPS_FLASHER)
    add_subdirectory(Flasher)
endif()

if(APPS_DEVSTUDIO AND NOT MINGW)
    add_subdirectory(DeveloperStudio)
endif()

if (APPS_SCI)
    add_subdirectory(SerialConsoleInterface)
endif()

if (APPS_PRT)
    add_subdirectory(PlatformRegistrationTool)
endif()
