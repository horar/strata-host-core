project(platform-identification-test
    VERSION 0.0.1
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME}
   src/main.cpp
   src/PlatformIdentificationTest.cpp
)

# add_library(${PROJECT_NAME}
#     src/templateLib.cpp
#     include/templateLib.h
# )

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
)

# link the serial stuff.
# link the jlink thing.
target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    BoardManager
    SerialDevice
    SGJLinkConnector
)

# target_include_directories(${PROJECT_NAME}
#     PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
# )

# if(BUILD_TESTING)
#     add_subdirectory(GtestTemplate)
#     add_subdirectory(QtestTemplate)
# endif()

set_target_properties(${PROJECT_NAME}
    PROPERTIES AUTOMOC ON
)
