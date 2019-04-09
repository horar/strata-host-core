project(EventsMgr
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Libevent2 REQUIRED)
find_package(Threads REQUIRED)

if (APPLE)
    find_library(IOKIT_LIBRARY IOKit)
    find_library(FOUNDATION_LIBRARY Foundation)
endif()

add_library(${PROJECT_NAME}
        src/EvEvent.cpp
        src/EvEventsMgr.cpp
        )

target_link_libraries(${PROJECT_NAME}
        PUBLIC ${LIBEVENT2_LIBRARIES}
        PUBLIC ${LIBEVENT2_PTHREAD_LIBRARIES}
        Threads::Threads
        )

if (APPLE)
    target_link_libraries(${PROJECT_NAME} PUBLIC ${IOKIT_LIBRARY} ${FOUNDATION_LIBRARY} )
endif()

if (WIN32)
    target_link_libraries(${PROJECT_NAME} PUBLIC Ws2_32.lib)
endif()

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC ${LIBEVENT2_INCLUDE_DIR}
)
