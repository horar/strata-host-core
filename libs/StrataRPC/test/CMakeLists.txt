project(StrataRPC-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

function(prepareTestExecutable)
    get_filename_component(EXECUTABLE_NAME ${ARGV0} NAME_WE)

    string(REPLACE "Test" "" EXECUTABLE_NAME ${EXECUTABLE_NAME})
    string(PREPEND EXECUTABLE_NAME "test-")

    add_executable(${EXECUTABLE_NAME} ${ARGV})

    target_link_libraries(${EXECUTABLE_NAME}
        PRIVATE Qt5::Test
        PRIVATE StrataRPC-StrataServer
        PRIVATE StrataRPC-StrataClient
    )

    target_include_directories(${EXECUTABLE_NAME}
        PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src
    )

    add_test(NAME ${EXECUTABLE_NAME}
        COMMAND ${EXECUTABLE_NAME}
    )
endfunction()

prepareTestExecutable(DispatcherTest.cpp TestHandlers.cpp)
prepareTestExecutable(ClientsControllerTest.cpp)
prepareTestExecutable(ConnectorsTest.cpp)
prepareTestExecutable(StrataServerTest.cpp)
prepareTestExecutable(StrataClientTest.cpp)
prepareTestExecutable(RequestsControllerTest.cpp)
prepareTestExecutable(StrataClientServerIntegrationTest.cpp)
