project(SGwget_Test VERSION 1.0)

add_executable(${PROJECT_NAME}
    src/test.cpp
)

target_link_libraries(${PROJECT_NAME}
       PRIVATE sgwget
)

