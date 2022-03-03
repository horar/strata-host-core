##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(PlatformManager-qtest LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

set(SOURCE_FILES
    PlatformManagerIntegrationTest.cpp
    PlatformManagerTest.cpp
    PlatformOperationsTest.cpp
    PlatformOperationsV2Test.cpp
    PlatformMessageTest.cpp
    PlatformErrorsTest.cpp
)

foreach(SOURCE_PATH ${SOURCE_FILES})

    get_filename_component(EXECUTABLE_NAME ${SOURCE_PATH} NAME_WE)

    string(REPLACE "Test" "" EXECUTABLE_NAME ${EXECUTABLE_NAME})
    string(PREPEND EXECUTABLE_NAME "test-")

    add_executable(${EXECUTABLE_NAME} ${SOURCE_PATH})

    target_link_libraries(${EXECUTABLE_NAME}
        PRIVATE Qt5::Test
        PRIVATE strata::Platform
        PRIVATE strata::PlatformManager
        PRIVATE strata::CommandValidator
        PRIVATE strata::base64
    )

    add_test(NAME ${EXECUTABLE_NAME}
        COMMAND ${EXECUTABLE_NAME}
    )

endforeach(SOURCE_PATH ${SOURCE_FILES})
