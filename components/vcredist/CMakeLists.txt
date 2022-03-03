##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
if (CMAKE_BUILD_TYPE STREQUAL "OTA")
    project(Vcredist
        DESCRIPTION "Visual C++ Redistributable for Visual Studio 2017"
        LANGUAGES NONE
    )

    set(PROJECT_BUNDLE_ID com.onsemi.strata.utils.common.vcredist)

    add_custom_target(${PROJECT_NAME})
    generate_ifw_version(GITTAG_PREFIX "vcredist_")

    file(COPY "${PROJECT_SOURCE_DIR}/resources/qtifw/packages_win/data" DESTINATION "${CMAKE_BINARY_DIR}/packages_win/${PROJECT_BUNDLE_ID}")
endif()

