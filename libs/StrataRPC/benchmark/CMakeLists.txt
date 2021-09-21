##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(StrataRPC-benchmark LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

set(SOURCE_FILES
    StrataServerBenchmark.cpp
    StrataClientBenchmark.cpp
)

foreach(SOURCE_PATH ${SOURCE_FILES})

    get_filename_component(EXECUTABLE_NAME ${SOURCE_PATH} NAME_WE)

    string(PREPEND EXECUTABLE_NAME "test-")

    add_executable(${EXECUTABLE_NAME} ${SOURCE_PATH})

    target_link_libraries(${EXECUTABLE_NAME}
        PRIVATE Qt5::Test
        PRIVATE StrataRPC-StrataServer
        PRIVATE StrataRPC-StrataClient
    )

    add_test(NAME ${EXECUTABLE_NAME}
        COMMAND ${EXECUTABLE_NAME}
    )

endforeach(SOURCE_PATH ${SOURCE_FILES})
