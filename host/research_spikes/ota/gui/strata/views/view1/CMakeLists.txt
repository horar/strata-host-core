project(view1
    VERSION 0.0.1.1
    DESCRIPTION "description_1"
    HOMEPAGE_URL "url_1"
    LANGUAGES NONE)

# install
install(FILES "README.md"
    DESTINATION views/${PROJECT_NAME}
    COMPONENT ${PROJECT_NAME}
)

# package
cpack_add_component_group(views1
    DISPLAY_NAME "${PROJECT_NAME}"
    DESCRIPTION "${PROJECT_DESCRIPTION}"
    PARENT_GROUP views
)
cpack_ifw_configure_component_group(views1
    NAME tech.spyglass.strata.views.view1
    VERSION ${PROJECT_VERSION}
    DEPENDS tech.spyglass.strata.sgwidgets
)

cpack_add_component(view1
    GROUP views1
    INSTALL_TYPES All
)
cpack_ifw_configure_component(view1
    NAME tech.spyglass.strata.views.view1
)
