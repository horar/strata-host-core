project(test-template
    VERSION 0.0.1
    LANGUAGES CXX
)

#add_executable(${PROJECT_NAME}
#    src/main.cpp
#)

add_library(${PROJECT_NAME}
    src/templateLib.cpp
    include/templateLib.h
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

add_subdirectory(GtestTemplate)
add_subdirectory(QtestTemplate)

set_target_properties(${PROJECT_NAME} ${PROJECT_NAME}-qtest
    PROPERTIES AUTOMOC ON
)
