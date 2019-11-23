project(command-validator-test
    VERSION 0.1
    LANGUAGES CXX
)

add_executable(command-validator-test
command-validator-test.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE CommandValidator
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
