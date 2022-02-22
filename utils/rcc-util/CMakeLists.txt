##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(rcc-util
    DESCRIPTION "RCC files utility"
    LANGUAGES CXX
)

set(PROJECT_BUNDLE_ID com.onsemi.strata.rccutil)
set(PROJECT_COPYRIGHT "Copyright (C) 2019-2022 ${PROJECT_COMPANY}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_executable(${PROJECT_NAME}
    src/main.cpp
)

generate_app_version(GITTAG_PREFIX "rccutil_" MACBUNDLE OFF)
generate_app_build_timestamp()

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON

    OUTPUT_NAME ${PROJECT_NAME}
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/$<IF:$<CONFIG:OTA>,packages/${PROJECT_BUNDLE_ID}/data,bin>
)

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
)

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)
