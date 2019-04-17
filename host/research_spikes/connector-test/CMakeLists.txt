project(ConnectorTest LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)

set(SCI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../apps/SerialConsoleInterface )

find_package(Qt5 5.12
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
    "main.cpp"
    "${SCI_DIR}/PlatformController.cpp"
)

add_test(testmain ${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Test connector)
if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
    )
endif()
