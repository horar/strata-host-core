find_package(Qt5 5.10
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME} STATIC
    QtLoggerSetup.cpp
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC SpdLogger
)

target_include_directories(${PROJECT_NAME} PUBLIC
    ${PROJECT_SOURCE_DIR}/inc
)
