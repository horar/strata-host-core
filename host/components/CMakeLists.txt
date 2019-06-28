add_subdirectory(theme)
add_subdirectory(fonts)
add_subdirectory(pdfjs)

add_subdirectory(sgwidgets)
add_subdirectory(common)
add_subdirectory(commoncpp)

option(BUILD_VIEWS "Build Strata 'view' components" ON)
add_feature_info(BUILD_VIEWS BUILD_VIEWS "Build Strata 'view' components")
add_subdirectory(views)
