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

option(APPS_VIEWS "Build Strata 'view' components" ON)
add_feature_info(APPS_VIEWS APPS_VIEWS "Build Strata 'view' components")
add_subdirectory(views)
