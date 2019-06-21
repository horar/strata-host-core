project(couchbase-browser
    VERSION 1.0.0
    LANGUAGES CXX
)

# Find the QtWidgets library
find_package(Qt5 COMPONENTS Widgets REQUIRED)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

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

#add_executable(${PROJECT_NAME}
#    src/main.cpp
#)

set(SRCS
    src/databaseinterface.cpp
    src/databaseinterface.h
    src/cb_browser.ui
    src/cb_browser.cpp
    src/cb_browser.h
    src/main.cpp
)

#qt5_wrap_ui(UI_HEADERS
#    src/cb_browser.ui
#)

add_executable(${PROJECT_NAME} ${SRCS})

#add_executable(${PROJECT_NAME} ${UI_HEADERS})

#add_executable(${PROJECT_NAME} ${SRCS} ${UI_HEADERS})

target_link_libraries(${PROJECT_NAME}
#    flasher
#    PlatformManager
#    StrataSerialPort
    couchbase-lite-cpp
    Qt5::Widgets
)





if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        ${IOKIT_LIB}
        ${FOUNDATION_LIB}
    )
endif()
