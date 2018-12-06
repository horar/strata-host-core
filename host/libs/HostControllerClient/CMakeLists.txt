cmake_minimum_required(VERSION 3.0)

project(HostControllerClient VERSION 1.0)

find_package(ZeroMQ REQUIRED)

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include
        ${ZEROMQ_INCLUDE_DIR}
        ${EXT_LIBS_PATH}/zmq/include
        )

add_library(${PROJECT_NAME}
    src/HostControllerClient.cpp
)

target_link_libraries(${PROJECT_NAME}
        PUBLIC ${ZEROMQ_LIBRARIES}
)

target_include_directories(${PROJECT_NAME}
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
        PUBLIC ${EXT_LIBS_PATH}/zmq/include
        )
