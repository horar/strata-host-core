project(crc16
    VERSION 1.0
    LANGUAGES CXX
)

add_library(${PROJECT_NAME} INTERFACE)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/include
)
