project(SGTextHighlighter
    VERSION 0.1
    LANGUAGES CXX
)
find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/SGTextHighlighter.cpp
    include/SGTextHighlighter.h
)

add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
    Qt5::Core
    Qt5::Quick
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test/CMakeLists.txt")
        add_subdirectory(test)
    endif()
endif()
