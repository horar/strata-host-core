cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

project(cb-browser-test
    VERSION 1.0
    LANGUAGES CXX
)

# Find the QtWidgets library
find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

get_filename_component(PARENT_DIR ${CMAKE_CURRENT_SOURCE_DIR} DIRECTORY)

set(SOURCES
    ${PARENT_DIR}/src/DatabaseImpl.cpp
    ${PARENT_DIR}/include/DatabaseImpl.h

    ${PARENT_DIR}/src/ConfigManager.cpp
    ${PARENT_DIR}/include/ConfigManager.h
)

add_executable(${PROJECT_NAME}
    cb-browser-test.cpp
    ${SOURCES}
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${PARENT_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE gtest::gtest
    couchbase-lite-cpp
    Qt5::Core
)

if (WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE Setupapi.lib Ws2_32.lib )
endif()

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()
