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

if(WIN32)
    add_custom_command(TARGET ${PROJECT_NAME}-test POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/ext_libs/libzmq/bin/windows/x64/libzmq.dll
            $<TARGET_FILE_DIR:${PROJECT_NAME}-test>
        COMMENT "Deploying dependant 3rd party libraries..."
        VERBATIM
    )
endif()

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)
