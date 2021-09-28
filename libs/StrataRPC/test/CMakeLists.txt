##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
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
