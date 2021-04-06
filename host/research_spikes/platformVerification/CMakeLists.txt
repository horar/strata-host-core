project(PlatformVerification
    DESCRIPTION "Platform Verification"
    LANGUAGES CXX
)

set(PROJECT_COPYRIGHT "Copyright (C) 2018-2021 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_executable(${PROJECT_NAME}
    src/main.cpp
    src/Verificator.cpp
    src/logging/LoggingQtCategories.cpp
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    strata::QtLogger
    strata::Platform
    strata::PlatformManager
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

generate_app_version(GITTAG_PREFIX "${PROJECT_NAME}_" MACBUNDLE OFF)
generate_app_build_timestamp()

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)
