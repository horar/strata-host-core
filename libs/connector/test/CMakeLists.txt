add_executable(test-${PROJECT_NAME}
    main.cpp
    connector-test.cpp
)

target_link_libraries(test-${PROJECT_NAME}
    PRIVATE connector
    PRIVATE gtest::gtest
)

if (WIN32)
    target_link_libraries(test-${PROJECT_NAME}
        PRIVATE Setupapi.lib Ws2_32.lib
    )
endif()

if (APPLE)
    target_link_libraries(test-${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()

add_test(NAME test-${PROJECT_NAME}
    COMMAND test-${PROJECT_NAME}
)
