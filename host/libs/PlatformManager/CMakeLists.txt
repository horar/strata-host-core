project(PlatformManager VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Threads REQUIRED)

set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../shared")

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
        PUBLIC SerialPort
        ${CMAKE_THREAD_LIBS_INIT}
)

if (APPLE)
    target_link_libraries(${PROJECT_NAME} PUBLIC ${IOKIT_LIBRARY} ${FOUNDATION_LIBRARY} )
endif()

target_include_directories(${PROJECT_NAME}
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
        PUBLIC ${SHARED_DIR}/rapidjson/include
)
