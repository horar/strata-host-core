project(view2
    VERSION 0.0.5.0
    DESCRIPTION "description_2"
    HOMEPAGE_URL "url_2"
    LANGUAGES NONE)

# install
install(FILES "README.md"
    DESTINATION views/${PROJECT_NAME}
    COMPONENT ${PROJECT_NAME}
)

# package
cpack_add_component_group(views2
    DISPLAY_NAME "${PROJECT_NAME}"
    DESCRIPTION "${PROJECT_DESCRIPTION}"
    PARENT_GROUP views
)
cpack_ifw_configure_component_group(views2
    NAME tech.spyglass.strata.views.view2
    VERSION ${PROJECT_VERSION}
    DEPENDS tech.spyglass.strata.sgwidgets
)

cpack_add_component(view2
    GROUP views2
    INSTALL_TYPES All
)
cpack_ifw_configure_component(view2
    NAME tech.spyglass.strata.views.view2
)
