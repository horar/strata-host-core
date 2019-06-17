project(HostControllerClient
    VERSION 1.0
    LANGUAGES CXX
)

add_library(${PROJECT_NAME}
    src/HostControllerClient.cpp
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC connector
)

target_include_directories(${PROJECT_NAME}
    PUBLIC include
)
