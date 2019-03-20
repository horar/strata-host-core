project(HostControllerClient VERSION 1.0)

find_package(ZeroMQ REQUIRED)
find_package(ZMQHelper REQUIRED)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(${PROJECT_NAME}
    src/HostControllerClient.cpp
)

target_link_libraries(${PROJECT_NAME}
        PUBLIC ${ZEROMQ_LIBRARIES}
        PUBLIC ZMQHelper
        PUBLIC ZeroMQ
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)
