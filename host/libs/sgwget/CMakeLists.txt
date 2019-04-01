project(SGwget VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Curl REQUIRED)
find_package(Threads REQUIRED)

add_library(sgwget
    src/SGwget.cpp
)

target_link_libraries(sgwget
      PUBLIC ${CURL_LIBRARIES}
      ${CMAKE_THREAD_LIBS_INIT}
)

target_include_directories(sgwget
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC ${CURL_INCLUDE_DIR}
    PUBLIC ${RAPIDJSON_INCLUDE_DIR}
)


