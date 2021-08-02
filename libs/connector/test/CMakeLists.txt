set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/tests")

add_executable(${PROJECT_NAME}-test
    main.cpp
    connector-test.cpp
)

target_link_libraries(${PROJECT_NAME}-test
    PRIVATE connector
    PRIVATE gtest::gtest
)

if (WIN32)
    target_link_libraries(${PROJECT_NAME}-test
        PRIVATE Setupapi.lib Ws2_32.lib
    )
endif()

if (APPLE)
    target_link_libraries(${PROJECT_NAME}-test
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)
