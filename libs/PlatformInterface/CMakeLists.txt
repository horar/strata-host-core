project(PlatformInterface
    VERSION 1.0.0
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/CoreInterface.cpp
    src/LoggingQtCategories.cpp
    # This is to let CMake know to run moc preprocessor on header files
    # with Q_OBJECT macro.
    include/PlatformInterface/core/CoreInterface.h
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC strata::HostControllerClient # TODO: remove this!
    PUBLIC strata::StrataRPC-StrataClient
    PRIVATE strata::QtLogger
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include/PlatformInterface
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)
