##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
add_subdirectory(qml)

if(BUILD_EXAMPLES)
    find_package(Qt5 ${VERSION_QT5}
        COMPONENTS Quick
        REQUIRED
    )

    add_subdirectory(qml/tech/strata/sgwidgets)
    add_subdirectory(qml/tech/strata/sgwidgets.1.0)
    add_subdirectory(qml/tech/strata/sglayout.1.0)
endif()
