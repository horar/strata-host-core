include(CMakeDependentOption)

option(APPS_HCS2 "Build 'hcs2' service" ON)
option(APPS_FLASHER "Build 'Flasher' app" ON)
cmake_dependent_option(APPS_STRATA "Build 'Strata Developer Studio' app" ON
                       "APPS_HCS2" OFF)
option(APPS_SCI "Build 'Serial Console Interface'" ON)
option(APPS_PRT "Build 'Platform Registration Tool'" ON)

if(APPS_HCS2)
    add_subdirectory(hcs2)
endif()
if(APPS_FLASHER)
    add_subdirectory(Flasher)
endif()
if(APPS_STRATA AND NOT MINGW)
    add_subdirectory(strata)
endif()

if (APPS_SCI AND NOT WIN32)
  # this is not supported on windows yet
  add_subdirectory(SerialConsoleInterface)
endif()

if (APPS_PRT AND NOT WIN32)
  # this is not supported on windows yet
  add_subdirectory(PlatformRegistrationTool)
endif()

# old stuff..
# add_subdirectory(HostNotification)
