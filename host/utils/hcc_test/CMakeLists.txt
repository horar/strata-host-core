cmake_minimum_required(VERSION 3.1)

project(hcc_test)

add_executable(${PROJECT_NAME}
        main.cpp
        )

target_link_libraries(${PROJECT_NAME} PRIVATE HostControllerClient)
