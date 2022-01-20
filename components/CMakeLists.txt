##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
option(APPS_CORECOMPONENTS "Build Strata application components" ON)
add_feature_info(APPS_CORECOMPONENTS APPS_CORECOMPONENTS "Build Strata application components")

if(APPS_CORECOMPONENTS)
    if (CMAKE_BUILD_TYPE STREQUAL "OTA")
        project(components
            DESCRIPTION "Strata Components"
            LANGUAGES NONE
        )

        set(PROJECT_BUNDLE_ID com.onsemi.strata.components)

        add_custom_target(${PROJECT_NAME})
        generate_ifw_version(GITTAG_PREFIX "components_")

        add_subdirectory(qt)
        add_subdirectory(addons)
        add_subdirectory(openssl)
        if(WIN32)
            add_subdirectory(vcredist)
            add_subdirectory(ftdi)
        endif()
    endif()

    add_subdirectory(theme)
    add_subdirectory(fonts)
    add_subdirectory(pdfjs)
    if(APPS_CORESW_SDS AND APPS_CORESW_SDS_PLUGIN_CVC)
        add_subdirectory(monaco)
    endif()
    add_subdirectory(sgwidgets)
    add_subdirectory(common)
    add_subdirectory(commoncpp)
endif()

if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/strata-platform-control-views")
    add_subdirectory(strata-platform-control-views)
endif()
