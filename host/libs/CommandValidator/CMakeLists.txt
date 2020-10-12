project(CommandValidator
    VERSION 0.1
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME}
	src/CommandValidator.cpp
	src/logging/LoggingQtCategories.cpp
    include/CommandValidator.h
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC strata::QtLogger
    PUBLIC rapidjson::rapidjson
)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
