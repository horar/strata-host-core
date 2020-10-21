project(HostControllerClient
    VERSION 1.0
    LANGUAGES CXX
)

add_library(${PROJECT_NAME}
    src/HostControllerClient.cpp
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
    PUBLIC strata::connector
)

target_include_directories(${PROJECT_NAME}
    PUBLIC include
)
