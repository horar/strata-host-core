
# package
cpack_add_component_group(views
    DISPLAY_NAME "Platform views"
    DESCRIPTION "platform views details..."
    PARENT_GROUP strata
)
cpack_ifw_configure_component_group(views
    NAME tech.spyglass.strata.views
    SORTING_PRIORITY 10
)

add_subdirectory(view1)
add_subdirectory(view2)
