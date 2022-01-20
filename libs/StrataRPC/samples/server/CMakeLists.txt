##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
project(strataRPC-ServerSample
    VERSION 0.0.1
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_executable(${PROJECT_NAME}
    main.cpp
    Server.cpp
    RandomGraph.cpp
    logging/LoggingQtCategories.cpp
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt5::Core
    PRIVATE StrataRPC-StrataServer
    PRIVATE strata::QtLogger
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES AUTOMOC ON
)