##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
if (CMAKE_BUILD_TYPE STREQUAL "OTA")
    project(UtilsWrapper
        DESCRIPTION "Third-party Utilities"
        LANGUAGES NONE
    )

    set(PROJECT_BUNDLE_ID com.onsemi.strata.utils)

    add_custom_target(${PROJECT_NAME})
    set(PROJECT_DEPENDENCIES "com.onsemi.strata.utils.ftdi,com.onsemi.strata.utils.common.vcredist")
    generate_ifw_version(GITTAG_PREFIX "utils_")
endif()

