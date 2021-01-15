project(StrataRPC-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_executable(${PROJECT_NAME}
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

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt5::Test
    PRIVATE StrataRPC
)

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src
)

add_test(NAME ${PROJECT_NAME}
    COMMAND ${PROJECT_NAME}
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES AUTOMOC ON
)
