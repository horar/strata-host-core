project(sgcouchbaselite-playground
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME} sgcouchbaselite.cpp)

target_link_libraries(${PROJECT_NAME}
    couchbase-lite-cpp
)
