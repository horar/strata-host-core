add_subdirectory(theme)
add_subdirectory(fonts)
add_subdirectory(pdfjs)

add_subdirectory(sgwidgets)
add_subdirectory(common)
add_subdirectory(commoncpp)

option(APPS_VIEWS "Build Strata 'view' components" ON)
add_feature_info(APPS_VIEWS APPS_VIEWS "Build Strata 'view' components")
add_subdirectory(views)
