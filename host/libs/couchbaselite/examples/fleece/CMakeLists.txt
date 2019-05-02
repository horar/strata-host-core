project(fleece-playground
    LANGUAGES CXX
)

if(APPLE)
    find_library(FOUNDATION_LIB Foundation REQUIRED)
    if (NOT FOUNDATION_LIB)
        message(FATAL_ERROR "Foundation framework not found")
    endif()
endif()

add_executable(${PROJECT_NAME} fleece.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE
    couchbase-lite-cpp
)

if(APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        ${FOUNDATION_LIBRARY}
    )
endif()
