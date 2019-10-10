cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

project(cb-browser-test
    VERSION 1.0
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME}
    cb-browser-test.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE gtest::gtest
    CouchbaseBrowserLibrary
)

if (WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE Setupapi.lib Ws2_32.lib )
endif()

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY}
    )
endif()
