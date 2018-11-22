cmake_minimum_required(VERSION 3.1)

list( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules" )

add_subdirectory(libs)

# applications
add_subdirectory(apps)


add_subdirectory(research_spikes)
