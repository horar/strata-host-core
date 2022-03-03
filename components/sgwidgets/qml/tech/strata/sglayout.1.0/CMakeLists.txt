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

file(GLOB SGLAYOUT_FOLDERS SG*)
foreach(SGLAYOUT_DIR ${SGLAYOUT_FOLDERS})
    if(IS_DIRECTORY ${SGLAYOUT_DIR} AND EXISTS "${SGLAYOUT_DIR}/CMakeLists.txt")
        get_filename_component(SGLAYOUT_NAME ${SGLAYOUT_DIR} NAME_WE)
        add_subdirectory(${SGLAYOUT_NAME})
    endif()
endforeach()

