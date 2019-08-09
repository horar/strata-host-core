project(hcs2      #old: HostControllerService
    VERSION 2.0
    LANGUAGES CXX
)

# Add Red color for errors
string(ASCII 27 Esc)
set(red "${Esc}[31m")
set(reset_color "${Esc}[m")

if (WIN32)
    message("Building WINDOWS")
elseif (UNIX AND NOT APPLE AND NOT WIN32)
    message("Building LINUX")
elseif (APPLE)
    message(STATUS "Building MAC")
else()
    message(FATAL_ERROR "unsupported operating system !")
endif ()

if (WIN32)
    message("TOOL CHAIN: windows")
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
elseif(UNIX AND NOT APPLE AND NOT WIN32)
    message("TOOL CHAIN: linux")
    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE RelWithDebInfo)
        # set(CMAKE_BUILD_TYPE Debug) # To enable debugging
    endif()

elseif (APPLE)
    message(STATUS "TOOL CHAIN: mac")

    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE RelWithDebInfo)
        # set(CMAKE_BUILD_TYPE Debug) # To enable debugging
    endif()

    find_library(IOKIT_LIBRARY IOKit)
    find_library(FOUNDATION_LIBRARY Foundation)
else()
    message(FATAL_ERROR "unsupported operating system !")
endif ()

set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../shared")
include_directories(
    "${SHARED_DIR}/rapidjson/include"   	#rapidjson submodule
)

find_package(Libevent2 REQUIRED)

# Base64 library (external)
add_library(libBase64 ${SHARED_DIR}/cpp-base64/base64.cpp)
target_include_directories(libBase64 PUBLIC ${SHARED_DIR}/cpp-base64)

# HostControllerService ----------------------------------------------------------

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}   # for logger
    ${LIBEVENT2_INCLUDE_DIR}
)

add_executable(${PROJECT_NAME}
    src/HostControllerService.cpp
    src/DiscoveryService.cpp
    src/ParseConfig.cpp
    src/SGCouchbaseLiteWrapper.cpp
    src/main.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE connector libBase64 sgwget
    PRIVATE strata::CouchbaseLiteCPP
    PRIVATE ${LIBEVENT2_LIBRARIES}
)
if(WIN32)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE Setupapi.lib Ws2_32.lib
	)
endif()

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "hcs"
)
