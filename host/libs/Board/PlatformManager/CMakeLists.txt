project(PlatformManager
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core SerialPort
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/PlatformManager.cpp
    src/logging/LoggingQtCategories.cpp

    #AUTOMOC wont find header if it is in different directory
    include/PlatformManager.h
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC Qt5::SerialPort
    PUBLIC strata::QtLogger
    PUBLIC strata::Platform
    PRIVATE strata::CommandValidator
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    add_compile_definitions(BUILD_TESTING)
    add_subdirectory(test)
endif()
