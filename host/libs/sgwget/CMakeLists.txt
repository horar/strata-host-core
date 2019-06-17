project(SGwget VERSION 1.0)

find_package(Curl REQUIRED)
find_package(Threads REQUIRED)

set(EXT_LIBS_PATH ${CMAKE_SOURCE_DIR}/ext_libs)

option(LIBS_SGWGET_TEST "Build 'SGwget_Test' service" OFF)

if(LIBS_SGWGET_TEST)
    add_subdirectory(test)
endif()

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
    PUBLIC ${EXT_LIBS_PATH}/threadpool
)