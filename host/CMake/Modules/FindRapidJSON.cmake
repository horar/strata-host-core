if( TARGET RapidJSON )
    return()
endif()

unset( RAPIDJSON_INCLUDE_DIR CACHE )
unset( RAPIDJSON_INCLUDE_DIR )

message( STATUS "Looking for RapidJSON library" )

set(SHARED_LIBS_PATH ${CMAKE_SOURCE_DIR}/../extern)

find_path( RAPIDJSON_INCLUDE_DIR "rapidjson/rapidjson.h" PATHS ${SHARED_LIBS_PATH}/rapidjson/include )

if (RAPIDJSON_INCLUDE_DIR)
  set(RAPIDJSON_FOUND TRUE)
endif()

if (RAPIDJSON_FOUND)

  message( STATUS "RapidJSON headers found at ${ZEROMQ_INCLUDE_DIR}" )

  add_library( RapidJSON UNKNOWN IMPORTED )
  set_property( TARGET RapidJSON PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${RAPIDJSON_INCLUDE_DIR}" )

  mark_as_advanced(
      RAPIDJSON_INCLUDE_DIR )

else()
  if (RapidJSON_FIND_REQUIRED)
    message(FATAL_ERROR "Could NOT find RapidJSON development files: ${ZEROMQ_INCLUDE_DIR}")
  endif()

endif()
