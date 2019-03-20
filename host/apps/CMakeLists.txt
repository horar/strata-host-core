cmake_minimum_required(VERSION 3.8)

add_subdirectory(hcs2)
add_subdirectory(Flasher)
add_subdirectory(strata)

if (NOT CROSSCOMPILE)
  # this is not supported on windows yet
  add_subdirectory(SerialConsoleInterface)
endif()

# old stuff..
# add_subdirectory(HostControllerService)
# add_subdirectory(HostNotification)
