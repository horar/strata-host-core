#
# https://github.com/sipwise/sems/blob/master/cmake/FindLibevent2.cmake
#

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

# TODO: add other platforms...
if (APPLE)
  set(PLATFORM_TYPE "mac")
elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
  set(PLATFORM_TYPE "linux")
elseif (WIN32)
  set(PLATFORM_TYPE "windows")
endif()

FIND_PATH(LIBEVENT2_INCLUDE_DIR event2/event.h HINTS ${EXT_LIBS_PATH}/libevent/include/ /usr/include/event2 )
FIND_LIBRARY(LIBEVENT2_LIBRARIES NAMES event libevent HINTS ${EXT_LIBS_PATH}/libevent/lib/${PLATFORM_TYPE} )
FIND_LIBRARY(LIBEVENT2_CORE_LIBRARIES NAMES event_core libevent_core HINTS ${EXT_LIBS_PATH}/libevent/lib/${PLATFORM_TYPE} )
FIND_LIBRARY(LIBEVENT2_EXTRA_LIBRARIES NAMES event_extra libevent_extra HINTS ${EXT_LIBS_PATH}/libevent/lib/${PLATFORM_TYPE} )
if (NOT WIN32)
  FIND_LIBRARY(LIBEVENT2_PTHREAD_LIBRARIES NAMES event_pthreads libevent_pthreads HINTS ${EXT_LIBS_PATH}/libevent/lib/${PLATFORM_TYPE} )
endif()

if(LIBEVENT2_INCLUDE_DIR AND LIBEVENT2_LIBRARIES AND LIBEVENT2_CORE_LIBRARIES AND LIBEVENT2_EXTRA_LIBRARIES)
    SET(LIBEVENT2_FOUND TRUE)
else()
    SET(LIBEVENT2_FOUND FALSE)
endif()

if(LIBEVENT2_FOUND)
    IF (NOT Libevent2_FIND_QUIETLY)
        MESSAGE(STATUS "Found libevent2 includes: ${LIBEVENT2_INCLUDE_DIR}/event2/event.h")
        MESSAGE(STATUS "Found libevent2 library: ${LIBEVENT2_LIBRARIES}")
        MESSAGE(STATUS "Found libevent2 core library: ${LIBEVENT2_CORE_LIBRARIES}")
        MESSAGE(STATUS "Found libevent2 extra library: ${LIBEVENT2_EXTRA_LIBRARIES}")
        MESSAGE(STATUS "Found libevent2 pthread library: ${LIBEVENT2_PTHREAD_LIBRARIES}")
    ENDIF (NOT Libevent2_FIND_QUIETLY)
else(LIBEVENT2_FOUND)
    if (Libevent2_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could NOT find libevent2 development files: ${LIBEVENT2_INCLUDE_DIR} :: ${LIBEVENT2_LIBRARIES}")
    endif()
endif()
