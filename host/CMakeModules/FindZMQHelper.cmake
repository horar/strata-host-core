if( TARGET ZeroMQ_Helper )
    return()
endif()

unset( ZMQHELP_LIBRARIES CACHE )
unset( ZMQHELP_LIBRARIES )
unset( ZMQHELP_INCLUDE_DIR CACHE )
unset( ZMQHELP_INCLUDE_DIR )

message( STATUS "Looking for ZeroMQ_helpers library" )

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

find_path( ZMQHELP_INCLUDE_DIR "zmq.hpp" PATHS ${EXT_LIBS_PATH}/zmq/include )

if (ZMQHELP_INCLUDE_DIR)
    set(ZMQHELPER_FOUND TRUE)
endif()

if (ZMQHELPER_FOUND)

    message( STATUS "ZMQ_Helper headers found at ${ZMQHELP_INCLUDE_DIR}" )

    add_library( ZMQ_Helper UNKNOWN IMPORTED )
    set_property( TARGET ZMQ_Helper PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${ZMQHELP_INCLUDE_DIR}" )

    mark_as_advanced(
            ZMQHELP_INCLUDE_DIR )
else()
    if (ZMQHELPER_FIND_REQUIRED)
        message(FATAL_ERROR "Could NOT find ZeroMQ_Helper development files: ${ZMQHELP_INCLUDE_DIR} ")
    endif()
endif()
