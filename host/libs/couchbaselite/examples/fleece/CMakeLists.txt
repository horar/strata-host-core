project(fleece-playground
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME} fleece.cpp)

target_link_libraries(${PROJECT_NAME}
    couchbase-lite-cpp
)
