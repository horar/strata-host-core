project(StrataComm-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

#set(CMAKE_AUTOMOC ON)

add_executable(${PROJECT_NAME}-test
    DispatcherTest.cpp
    TestHandlers.cpp
    ClientsControllerTest.cpp
    ConnectorsTest.cpp
    StrataServerTest.cpp
    StrataClientTest.cpp
    RequestsControllerTest.cpp
    StrataClientServerIntegrationTest.cpp
    main.cpp
)

target_link_libraries(${PROJECT_NAME}-test
    PRIVATE Qt5::Test
    PRIVATE StrataComm
)

add_test(NAME ${PROJECT_NAME}-test
    COMMAND ${PROJECT_NAME}-test
)

set_target_properties(${PROJECT_NAME}-test
    PROPERTIES AUTOMOC ON
)
