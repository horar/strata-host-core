project(PlatformManager
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Threads REQUIRED)

set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../extern")

if (APPLE)
    find_library(IOKIT_LIBRARY IOKit)
    find_library(FOUNDATION_LIBRARY Foundation)
endif()

add_library(${PROJECT_NAME}
    src/PlatformManager.cpp
    src/PlatformConnection.cpp
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC EventsMgr
    PUBLIC StrataSerialPort
    PUBLIC Threads::Threads
    PUBLIC rapidjson::rapidjson
)

if (APPLE)
    target_link_libraries(${PROJECT_NAME} PUBLIC ${IOKIT_LIBRARY} ${FOUNDATION_LIBRARY} )
endif()

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)
