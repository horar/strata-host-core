##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
if (CMAKE_BUILD_TYPE STREQUAL "OTA")
    project(cvc_plugin
        DESCRIPTION "Control View Creator"
        LANGUAGES NONE
    )

    set(PROJECT_BUNDLE_ID com.onsemi.strata.devstudio.cvc)

    add_custom_target(${PROJECT_NAME})

    get_target_property(QT_RCC_EXECUTABLE Qt5::rcc IMPORTED_LOCATION)
    if(QT_RCC_EXECUTABLE STREQUAL "")
      message(FATAL_ERROR "Could not locate Qt RCC compiler executable.")
    else()
        if(EXISTS ${QT_RCC_EXECUTABLE})
            message(STATUS "Copying Qt RCC compiler executable from ${QT_RCC_EXECUTABLE}")

            get_filename_component(QT_RCC_EXECUTABLE_NAME ${QT_RCC_EXECUTABLE} NAME)
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${QT_RCC_EXECUTABLE} ${CMAKE_BINARY_DIR}/packages/${PROJECT_BUNDLE_ID}/data/${QT_RCC_EXECUTABLE_NAME}
            )
        else()
            message(FATAL_ERROR "Could not locate Qt RCC compiler executable: '${QT_RCC_EXECUTABLE}'")
        endif()
    endif()

    generate_ifw_version(GITTAG_PREFIX "cvc_")
endif()

