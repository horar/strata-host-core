project(serial_test
    LANGUAGES CXX
)

find_package(SerialPort REQUIRED)

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

add_executable(${PROJECT_NAME}
        main.cpp
        )

target_include_directories(${PROJECT_NAME}
        PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include
        PRIVATE ${SERIALPORT_INCLUDE_DIR}
        )

target_link_libraries(${PROJECT_NAME}
        PUBLIC ${SERIALPORT_LIBRARIES}
        )

if (APPLE)
    target_link_libraries(${PROJECT_NAME} PUBLIC ${IOKIT_LIB} ${FOUNDATION_LIB} )
endif()

if (WIN32)
    target_link_libraries(${PROJECT_NAME} LINK_PUBLIC SetupAPI.lib  )
endif()
