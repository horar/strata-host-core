##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
include(AddSgWidgetExampleMacro)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

file(GLOB SGWIDGETS_FOLDERS SG*)
foreach(SGWIDGET_DIR ${SGWIDGETS_FOLDERS})
    if(IS_DIRECTORY ${SGWIDGET_DIR} AND EXISTS "${SGWIDGET_DIR}/CMakeLists.txt")
        get_filename_component(SGWIDGETS_NAME ${SGWIDGET_DIR} NAME_WE)
        add_subdirectory(${SGWIDGETS_NAME})
    endif()
endforeach()

