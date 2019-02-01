project(EventsMgr VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Libevent2 REQUIRED)
find_package(Threads REQUIRED)

if (APPLE)
    find_library(IOKIT_LIBRARY IOKit)
    find_library(FOUNDATION_LIBRARY Foundation)
endif()

include_directories(${SERIALPORT_INCLUDE_DIR} )

add_library(${PROJECT_NAME}
        src/EventsMgr.cpp
        )

target_link_libraries(${PROJECT_NAME}
        PUBLIC ${LIBEVENT2_LIBRARIES}
        PUBLIC ${LIBEVENT2_PTHREAD_LIBRARIES}
        Threads::Threads
        )

if (APPLE)
    target_link_libraries(${PROJECT_NAME} PUBLIC ${IOKIT_LIBRARY} ${FOUNDATION_LIBRARY} )
endif()

target_include_directories(${PROJECT_NAME}
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
        )





