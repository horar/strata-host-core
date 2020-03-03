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
        # REQUIRED
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# target_link_libraries(${PROJECT_NAME}
#     PRIVATE rapidjson::rapidjson
# )

if(BUILD_TESTING)
    add_subdirectory(Gtest)
    add_subdirectory(QtestTemplate)
endif()
