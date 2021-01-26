find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME} STATIC
    QtLogger.cpp
    QtLoggerSetup.cpp
    LoggingQtCategories.cpp
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

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

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=0x051200
)
