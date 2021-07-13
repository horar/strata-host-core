project(EventsMgr
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Threads REQUIRED)

if (APPLE)
    find_library(IOKIT_LIBRARY IOKit)
    find_library(FOUNDATION_LIBRARY Foundation)
endif()

add_library(${PROJECT_NAME}
    src/EvEventBase.cpp
    src/EvEvent.cpp
    src/EvEventsMgr.cpp
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

if(WIN32)
    target_sources(${PROJECT_NAME} PRIVATE
        src/win32/EvCommEvent.cpp
        src/win32/EvCommWaitManager.cpp
        src/win32/EvTimerEvent.cpp
        src/win32/EvEventsMgrInstance.cpp
    )
endif()

target_link_libraries(${PROJECT_NAME}
    PUBLIC Threads::Threads
    PUBLIC libevent::libevent
)

if (APPLE)
    target_link_libraries(${PROJECT_NAME} PUBLIC
        ${IOKIT_LIBRARY}
        ${FOUNDATION_LIBRARY}
    )
endif()

if (WIN32)
    target_link_libraries(${PROJECT_NAME} PUBLIC
        Ws2_32.lib
    )
endif()

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)
