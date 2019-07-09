project(cb-browser-test
    VERSION 1.0
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME}
    cb-browser-test.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE cbtest
    PRIVATE gtest::gtest
)

if (WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE Setupapi.lib Ws2_32.lib )
endif()

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()
