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
    endif()

    add_subdirectory(theme)
    add_subdirectory(fonts)
    add_subdirectory(pdfjs)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_subdirectory(monaco)
    endif()
    add_subdirectory(sgwidgets)
    add_subdirectory(common)
    add_subdirectory(commoncpp)
endif()

option(APPS_VIEWS "Build Strata 'control-view' components" ON)
add_feature_info(APPS_VIEWS APPS_VIEWS "Build Strata 'control-view' components")
# LC: we don't protect subdirectory with above variable here;
# it is done inside CMake macro per view project as disabled view is removed from filesystem
add_subdirectory(views)
