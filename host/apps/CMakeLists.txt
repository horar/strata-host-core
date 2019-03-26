include(CMakeDependentOption)

option(APPS_HCS2 "Build 'hcs2' service" ON)
option(APPS_FLASHER "Build 'Flasher' app" ON)
cmake_dependent_option(APPS_STRATA "Build 'Strata Developer Studio' app" ON
                       "APPS_HCS2" OFF)
option(APPS_SCI "Build 'Serial Console Interface'" ON)

if(APPS_HCS2)
    add_subdirectory(hcs2)
endif()
if(APPS_FLASHER)
    add_subdirectory(Flasher)
endif()
if(APPS_STRATA AND NOT MINGW)
    add_subdirectory(strata)
endif()

if (APPS_SCI AND NOT CROSSCOMPILE)
  # this is not supported on windows yet
  add_subdirectory(SerialConsoleInterface)
endif()

# old stuff..
# add_subdirectory(HostControllerService)
# add_subdirectory(HostNotification)
