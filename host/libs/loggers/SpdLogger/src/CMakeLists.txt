add_library(${PROJECT_NAME} STATIC
    SpdLogger.cpp
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC spdlog::spdlog
)

target_include_directories(${PROJECT_NAME} PUBLIC
    ${PROJECT_SOURCE_DIR}/include
)
