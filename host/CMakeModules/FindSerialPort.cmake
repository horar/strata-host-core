if( TARGET serialport )
    return()
endif()

unset( SERIAL_PORT_LIBRARIES CACHE )
unset( SERIAL_PORT_LIBRARIES )
unset( SERIAL_PORT_INCLUDE_DIR CACHE )
unset( SERIAL_PORT_INCLUDE_DIR )

message( STATUS "Looking for Serial port library" )

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

# TODO: add other platforms...
if (APPLE)
  set(PLATFORM_TYPE "mac")
elseif(UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
  set(PLATFORM_TYPE "linux")
elseif (CROSSCOMPILE)
  message(FATAL_ERROR "Not unsupported yet!")
endif()

find_library( SERIAL_PORT_LIBRARIES NAMES "serialport" PATHS ${EXT_LIBS_PATH}/libserial/lib/${PLATFORM_TYPE} )
find_path( SERIAL_PORT_INCLUDE_DIR "libserialport.h" PATHS ${EXT_LIBS_PATH}/libserial/include )
if( NOT SERIAL_PORT_INCLUDE_DIR )
   message( FATAL_ERROR "Serial port includes not found")
endif()
if( NOT SERIAL_PORT_LIBRARIES )
   message( FATAL_ERROR "Serial port libraries not found")
endif()

message( STATUS "Serial port found at ${SERIAL_PORT_LIBRARIES}" )

add_library( serialport UNKNOWN IMPORTED )
set_property( TARGET serialport PROPERTY IMPORTED_LOCATION "${SERIAL_PORT_LIBRARIES}" )
set_property( TARGET serialport PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${SERIAL_PORT_INCLUDE_DIR}" )

mark_as_advanced(
    SERIAL_PORT_LIBRARIES
    SERIAL_PORT_INCLUDE_DIR )
