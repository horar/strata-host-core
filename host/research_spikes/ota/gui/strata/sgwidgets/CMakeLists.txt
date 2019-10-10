project(sgwidgets
    VERSION 0.0.11
    DESCRIPTION "Spyglass widgets"
    HOMEPAGE_URL "url_1"
    LANGUAGES NONE)

# install
install(FILES "README.md"
    DESTINATION ${PROJECT_NAME}
    COMPONENT ${PROJECT_NAME}
)

# package
cpack_add_component_group(sgw
    DISPLAY_NAME "${PROJECT_DESCRIPTION}"
    DESCRIPTION "TODO"
    PARENT_GROUP strata
)
cpack_ifw_configure_component_group(sgw
    NAME tech.spyglass.strata.sgwidgets
    VERSION ${PROJECT_VERSION}
    SORTING_PRIORITY 20
)

# sgwidgets
cpack_add_component(sgwidgets
    GROUP sgw
    INSTALL_TYPES Runtime All
)
cpack_ifw_configure_component(sgwidget
    NAME tech.spyglass.strata.sgwidgets
)
