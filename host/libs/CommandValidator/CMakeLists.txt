project(CommandValidator
    VERSION 0.1
    LANGUAGES CXX
)

add_library(${PROJECT_NAME}
    src/CommandValidator.cpp
    include/CommandValidator.h
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE rapidjson::rapidjson
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
