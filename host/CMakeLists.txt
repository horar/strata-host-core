cmake_minimum_required(VERSION 3.1)

list( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules" )

if (APPLE)
  find_program( BREW_PROGRAM brew )
  mark_as_advanced(BREW_PROGRAM)
  if( BREW_PROGRAM )
    find_program( SED_PROGRAM sed )
    mark_as_advanced(SED_PROGRAM)
    find_program( BASH_PROGRAM bash )
    mark_as_advanced(BASH_PROGRAM)
    if( BASH_PROGRAM AND SED_PROGRAM )
      execute_process( COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} config | ${SED_PROGRAM} -n -E 's/^HOMEBREW_PREFIX: (.+)$$/\\1/p'" OUTPUT_VARIABLE HOMEBREW_PREFIX )
      string( STRIP "${HOMEBREW_PREFIX}" HOMEBREW_PREFIX )

      list( APPEND CMAKE_PREFIX_PATH
              "${HOMEBREW_PREFIX}/opt/qt"
              )

    endif()
  endif()
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

add_subdirectory(libs)
add_subdirectory(apps)
add_subdirectory(ui) # LC: temporary enable; later will be re-located in project tree
#add_subdirectory(test)
add_subdirectory(utils)
add_subdirectory(research_spikes)
