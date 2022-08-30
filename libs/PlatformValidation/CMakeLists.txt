##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(PlatformValidation
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

add_library(${PROJECT_NAME}
    src/logging/LoggingQtCategories.cpp
    src/Commands/BaseValidation.cpp
    src/Commands/Identification.cpp
    src/Commands/BootloaderApplication.cpp
    src/Commands/EmbeddedRegistration.cpp
    src/Commands/AssistedRegistration.cpp
    src/Flashing/FirmwareFlashing.cpp

    #AUTOMOC wont find header if it is in different directory
    include/ValidationStatus.h
    include/Commands/BaseValidation.h
    include/Commands/Identification.h
    include/Commands/BootloaderApplication.h
    include/Commands/EmbeddedRegistration.h
    include/Commands/AssistedRegistration.h
    include/Flashing/FirmwareFlashing.h
)
add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include/Commands
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include/Flashing
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Commands
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/Flashing

    # include commands needed for validations (from strata::Platform library)
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../Board/Platform/src/Operations/Commands
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC rapidjson::rapidjson
    PUBLIC strata::QtLogger
    PUBLIC strata::Platform
    PUBLIC strata::Flasher
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=${VERSION_QT5_DEPRECATE_BEFORE}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)
