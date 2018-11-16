if( TARGET ZeroMQ )
    return()
endif()

unset( ZEROMQ_LIBRARIES CACHE )
unset( ZEROMQ_LIBRARIES )
unset( ZEROMQ_INCLUDE_DIR CACHE )
unset( ZEROMQ_INCLUDE_DIR )

message( STATUS "Looking for ZeroMQ library" )

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

# TODO: add other platforms...
if (APPLE)
  set(PLATFORM_TYPE "mac")
elseif(UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
  set(PLATFORM_TYPE "linux")
elseif (CROSSCOMPILE)
  message(FATAL_ERROR "Not unsupported yet!")
endif()

find_library( ZEROMQ_LIBRARIES NAMES "zmq" PATHS ${EXT_LIBS_PATH}/libzmq/lib/${PLATFORM_TYPE} )
find_path( ZEROMQ_INCLUDE_DIR "zmq.h" PATHS ${EXT_LIBS_PATH}/libzmq/include )

if (ZEROMQ_INCLUDE_DIR AND ZEROMQ_LIBRARIES)
  set(ZEROMQ_FOUND TRUE)
endif()

if (ZEROMQ_FOUND)

  message( STATUS "ZeroMQ found at ${ZEROMQ_LIBRARIES}" )
  message( STATUS "ZeroMQ headers found at ${ZEROMQ_INCLUDE_DIR}" )

  add_library( ZeroMQ UNKNOWN IMPORTED )
  set_property( TARGET ZeroMQ PROPERTY IMPORTED_LOCATION "${ZEROMQ_LIBRARIES}" )
  set_property( TARGET ZeroMQ PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${ZEROMQ_INCLUDE_DIR}" )

  mark_as_advanced(
      ZEROMQ_LIBRARIES
      ZEROMQ_INCLUDE_DIR )
else()
  if (ZeroMQ_FIND_REQUIRED)
    message(FATAL_ERROR "Could NOT find ZeroMQ development files: ${ZEROMQ_INCLUDE_DIR} :: ${ZEROMQ_LIBRARIES}")
  endif()

endif()
