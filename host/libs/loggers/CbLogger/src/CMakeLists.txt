find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME} STATIC
    CbLoggerSetup.cpp
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core

    PRIVATE strata::CouchbaseLiteCPP
)

target_include_directories(${PROJECT_NAME} PUBLIC
    ${PROJECT_SOURCE_DIR}/include
)
