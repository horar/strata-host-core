project(hcc_test
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME}
    main.cpp
)

target_link_libraries(${PROJECT_NAME} PRIVATE HostControllerClient)

if (WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE Setupapi.lib Ws2_32.lib )
endif()

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()
