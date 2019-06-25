project(BoardsController
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/BoardsController.cpp
    src/PlatformBoard.cpp
    src/logging/LoggingQtCategories.cpp

    #AUTOMOC wont find header if it is in different directory
    include/BoardsController.h
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC PlatformManager
    PUBLIC QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)
