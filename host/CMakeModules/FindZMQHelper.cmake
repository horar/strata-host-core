if( TARGET ZMQHelper )
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
    set(ZMQHelper_FOUND TRUE)
endif()

if (ZMQHelper_FOUND)

    message( STATUS "ZMQHelper headers found at ${ZMQHELP_INCLUDE_DIR}" )

    add_library( ZMQHelper UNKNOWN IMPORTED )
    set_property( TARGET ZMQHelper PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${ZMQHELP_INCLUDE_DIR}" )

    mark_as_advanced(
            ZMQHELP_INCLUDE_DIR )
else()
    if (ZMQHelper_FIND_REQUIRED)
        message(FATAL_ERROR "Could NOT find ZMQHelper development files: ${ZMQHELP_INCLUDE_DIR} ")
    endif()
endif()
