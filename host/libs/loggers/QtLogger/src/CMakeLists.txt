find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME} STATIC
    QtLoggerSetup.cpp
    LoggingQtCategories.cpp
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC SpdLogger
)

target_include_directories(${PROJECT_NAME} PUBLIC
    ${PROJECT_SOURCE_DIR}/include
)
