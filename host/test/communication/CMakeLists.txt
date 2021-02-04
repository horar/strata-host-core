project(communication-test
    VERSION 1.0.0
    LANGUAGES CXX
)

add_executable(${PROJECT_NAME}
    ${CMAKE_CURRENT_SOURCE_DIR}/zmq_client.cpp
)

target_link_libraries(${PROJECT_NAME}
      zeromq::libzmq
      zeromq::cppzmq
      rapidjson::rapidjson
)
