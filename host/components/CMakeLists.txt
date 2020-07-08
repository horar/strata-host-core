option(APPS_CORECOMPONENTS "Build Strata application components" ON)
add_feature_info(APPS_CORECOMPONENTS APPS_CORECOMPONENTS "Build Strata application components")

if(APPS_CORECOMPONENTS)
    add_subdirectory(theme)
    add_subdirectory(fonts)
    add_subdirectory(pdfjs)

    add_subdirectory(sgwidgets)
    add_subdirectory(common)
    add_subdirectory(commoncpp)
endif()

option(APPS_VIEWS "Build Strata 'control-view' components" ON)
add_feature_info(APPS_VIEWS APPS_VIEWS "Build Strata 'control-view' components")
# LC: we don't protect subdirectory with above variable here;
# it is done inside CMake macro per view project as disabled view is removed from filesystem
add_subdirectory(views)
