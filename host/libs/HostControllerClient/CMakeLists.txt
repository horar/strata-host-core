project(HostControllerClient VERSION 1.0)

find_package(ZeroMQ REQUIRED)
find_package(ZMQHelper REQUIRED)

add_library(${PROJECT_NAME}
    src/HostControllerClient.cpp
)

target_link_libraries(${PROJECT_NAME}
        PUBLIC ${ZEROMQ_LIBRARIES}
)

target_include_directories(${PROJECT_NAME}
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
        PUBLIC ${ZEROMQ_INCLUDE_DIR}
        PUBLIC ${ZMQHELP_INCLUDE_DIR}
        )
