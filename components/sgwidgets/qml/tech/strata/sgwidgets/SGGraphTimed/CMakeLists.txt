##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
get_filename_component(ProjectId ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" ProjectId ${ProjectId})
project(SGWidgetsExample-${ProjectId} LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Widgets
    REQUIRED
)

add_sgwidget_example(
    NAME ${PROJECT_NAME}
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Widgets
)
