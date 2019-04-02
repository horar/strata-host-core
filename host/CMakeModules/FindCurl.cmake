if( TARGET Curl )
    return()
endif()

unset( CURL_LIBRARIES CACHE )
unset( CURL_LIBRARIES )
unset( CURL_INCLUDE_DIR CACHE )
unset( CURL_INCLUDE_DIR )

message( STATUS "Looking for Curl library" )

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

# TODO: add other platforms...
if (APPLE)
  set(PLATFORM_TYPE "mac")
elseif(UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
  set(PLATFORM_TYPE "linux")
elseif (WIN32)
  set(PLATFORM_TYPE "windows")
endif()

if(WIN32)
find_library( CURL_LIBRARIES NAMES "libcurl_imp" PATHS ${EXT_LIBS_PATH}/libcurl/lib/${PLATFORM_TYPE} )
else()
find_library( CURL_LIBRARIES NAMES "curl" PATHS ${EXT_LIBS_PATH}/libcurl/lib/${PLATFORM_TYPE} )
endif()
find_path( CURL_INCLUDE_DIR "curl.h" PATHS ${EXT_LIBS_PATH}/libcurl/include )

if (CURL_INCLUDE_DIR AND CURL_LIBRARIES)
  set(CURL_FOUND TRUE)
endif()

if (CURL_FOUND)

  message( STATUS "CURL found at ${CURL_LIBRARIES}" )
  message( STATUS "CURL headers found at ${CURL_INCLUDE_DIR}" )

  add_library( Curl UNKNOWN IMPORTED )
  set_property( TARGET Curl PROPERTY IMPORTED_LOCATION "${CURL_LIBRARIES}" )
  set_property( TARGET Curl PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${CURL_INCLUDE_DIR}" )

  mark_as_advanced(
      CURL_LIBRARIES
      CURL_INCLUDE_DIR )
else()
  if (Curl_FIND_REQUIRED)
    message(FATAL_ERROR "Could NOT find Curl development files: ${CURL_INCLUDE_DIR} :: ${CURL_LIBRARIES}")
  endif()

endif()
