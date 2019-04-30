project(connector-test
    VERSION 1.0
    LANGUAGES CXX
)


add_executable(connector-test
    connector-test.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE connector
    PRIVATE gtest
)

if (WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE Setupapi.lib Ws2_32.lib )
endif()

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()
