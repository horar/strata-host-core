project(flasher-app)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

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

add_executable(${PROJECT_NAME} src/main.cpp)

target_link_libraries(${PROJECT_NAME}
    flasher
    PlatformManager
    StrataSerialPort
)

if (APPLE)
    target_link_libraries(${PROJECT_NAME} ${IOKIT_LIB} ${FOUNDATION_LIB} )
endif()
