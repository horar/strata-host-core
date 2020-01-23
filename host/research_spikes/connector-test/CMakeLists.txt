project(ConnectorLiveTest
    LANGUAGES CXX
)

set(SCI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../apps/SerialConsoleInterface )

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Test
    REQUIRED
)
if(APPLE)
    find_library(IOKIT_LIB IOKit REQUIRED)
    if (NOT IOKIT_LIB)
        message(FATAL_ERROR "IOKit framework not found")
    endif()
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()
endif()

#temporary RS hack solution for testing
include_directories(${SCI_DIR})

add_executable(${PROJECT_NAME}
    main.cpp
    TestPlatformController.cpp
    ${SCI_DIR}/PlatformController.cpp
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Test

    connector
)

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
    )
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

# LC: temporary out; this tests requires connected board; then don't trigger with CTest
#add_test(NAME ${PROJECT_NAME}
#    COMMAND ${PROJECT_NAME}
#)
