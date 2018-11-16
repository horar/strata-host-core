if( TARGET SerialPort )
    return()
endif()

unset( SERIALPORT_LIBRARIES CACHE )
unset( SERIALPORT_LIBRARIES )
unset( SERIALPORT_INCLUDE_DIR CACHE )
unset( SERIALPORT_INCLUDE_DIR )

message( STATUS "Looking for SerialPort library" )

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

# TODO: add other platforms...
if (APPLE)
  set(PLATFORM_TYPE "mac")
elseif(UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
  set(PLATFORM_TYPE "linux")
elseif (CROSSCOMPILE)
  message(FATAL_ERROR "Not unsupported yet!")
endif()

find_library( SERIALPORT_LIBRARY NAMES "serialport" PATHS ${EXT_LIBS_PATH}/libserial/lib/${PLATFORM_TYPE} )
find_path( SERIALPORT_INCLUDE_DIR "libserialport.h" PATHS ${EXT_LIBS_PATH}/libserial/include )

if (SERIALPORT_INCLUDE_DIR AND SERIALPORT_LIBRARY)
  set(SERIALPORT_FOUND TRUE)
endif()

if (SERIALPORT_FOUND)
  message( STATUS "Serial port found at ${SERIALPORT_LIBRARY}" )

  add_library( SerialPort UNKNOWN IMPORTED )
  set_property( TARGET SerialPort PROPERTY IMPORTED_LOCATION "${SERIALPORT_LIBRARY}" )
  set_property( TARGET SerialPort PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${SERIALPORT_INCLUDE_DIR}" )

  set(SERIALPORT_LIBRARIES ${SERIALPORT_LIBRARY} )
  set(SERIALPORT_INCLUDE_DIRS ${SERIALPORT_INCLUDE_DIR} )

  mark_as_advanced(
      SERIALPORT_LIBRARY
      SERIALPORT_INCLUDE_DIR
      SERIALPORT_LIBRARIES
      SERIALPORT_INCLUDE_DIRS )

else (SERIALPORT_FOUND)
    if (SerialPort_FIND_REQUIRED)
      message(FATAL_ERROR "Could NOT find libSerialPort development files: ${SERIALPORT_INCLUDE_DIR} :: ${SERIALPORT_LIBRARIES}")
    endif()
endif()
