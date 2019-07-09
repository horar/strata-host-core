cmake_minimum_required(VERSION 3.1)

project(strata
    VERSION 0.0.5
    DESCRIPTION "Strata Developer Studio"
    HOMEPAGE_URL "https://www.onsemi.com/"
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


# ---------------------------------------------------------------------------
# dependenceis
# ---------------------------------------------------------------------------
find_package(Qt5 COMPONENTS Core Widgets Quick Qml REQUIRED)

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    main.cpp
    UpdateWatchdog.cpp
    qml.qrc
)
target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)
target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt5::Core Qt5::Quick
)

#if ("${CMAKE_CXX_COMPILER_ID}" IN_LIST "GNU;AppleClang")
#    target_compile_options(
#        ${PROJECT_NAME}
#        PRIVATE
#            -Wall
#            -Wextra
#            -Wpedantic
#    )
#endif()

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${CMAKE_CURRENT_SOURCE_DIR}/strata-installer-noninteractive.qs  $<TARGET_FILE_DIR:${PROJECT_NAME}>
)

# ---------------------------------------------------------------------------
# install stage
# ---------------------------------------------------------------------------
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION . COMPONENT application
    BUNDLE DESTINATION . COMPONENT application
)

install(FILES "${CMAKE_SOURCE_DIR}/README.md" DESTINATION . COMPONENT application)
install(FILES "${CMAKE_SOURCE_DIR}/LICENSE_beerware.txt" DESTINATION . COMPONENT application)
install(FILES "${CMAKE_SOURCE_DIR}/LICENSE_gpl-3.0.txt" DESTINATION . COMPONENT application)


# fixup the bundle
get_target_property(QT_LIBRARY_DIR Qt5::Core LOCATION)
get_filename_component(QT_LIBRARY_DIR ${QT_LIBRARY_DIR} PATH)
get_filename_component(QT_LIBRARY_DIR "${QT_LIBRARY_DIR}/.." ABSOLUTE)
list(APPEND libSearchDirs ${QT_LIBRARY_DIR})

if(WIN32)
    set(APPS "\${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.exe")
elseif(APPLE)
    set(APPS "\${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.app")
    list(APPEND libSearchDirs "")

    get_target_property(_qcocoa_dylib Qt5::QCocoaIntegrationPlugin LOCATION)
    if(NOT Qt5Core_VERSION STRLESS "5.10")
        get_target_property(_qmacstyle_dylib Qt5::QMacStylePlugin LOCATION)
    endif()

    # Qt Platform Plugin
    install(FILES
        ${_qcocoa_dylib}
        DESTINATION ${PROJECT_NAME}.app/Contents/PlugIns/platforms
        COMPONENT application
    )
    set(additionalLib \${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.app/Contents/PlugIns/platforms/libqcocoa.dylib)
    if(NOT Qt5Core_VERSION STRLESS "5.10")
        install(FILES
            ${_qmacstyle_dylib}
            DESTINATION ${PROJECT_NAME}.app/Contents/PlugIns/styles
            COMPONENT application
        )
        set(additionalLib
            ${additionalLib}
            \${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.app/Contents/PlugIns/styles/libqmacstyle.dylib
        )
    endif()
    install(FILES
        ${CMAKE_SOURCE_DIR}/qt.conf
        DESTINATION ${PROJECT_NAME}.app/Contents/Resources
        COMPONENT application
    )
else()
    message(FATAL_ERROR "Unknown platform - can't create bundle!!")
endif()


install(CODE "
    include(BundleUtilities)
    if(APPLE)
        set(BU_CHMOD_BUNDLE_ITEMS on)
    endif()
    fixup_bundle(\"${APPS}\" \"${additionalLib}\" \"${libSearchDirs}\")
    " DESTINATION . COMPONENT application
)



# ---------------------------------------------------------------------------
# CPack stage
# ---------------------------------------------------------------------------
set(CPACK_IFW_ROOT "c:/Dev/Qt/Tools/QtInstallerFramework/3.0")

set(CPACK_GENERATOR "IFW")

set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_VENDOR "ON Semiconductor")
#if(WIN32)
    set(CPACK_PACKAGE_DESCRIPTION "TODO: description OR description file")
    # or
    #set(CPACK_PACKAGE_DESCRIPTION_FILE "blablabla.txt")
#endif()
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CMAKE_PROJECT_NAME} ... description summary")
set(CPACK_PACKAGE_HOMEPAGE_URL "${CMAKE_PROJECT_HOMEPAGE_URL}")
#set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_SYSTEM_NAME}")
if(WIN32)
    set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/onLogoGreen.ico")
#    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}\\\\v${PROJECT_VERSION}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_DESCRIPTION}")
elseif(UNIX)
    if (APPLE)
        set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/onLogoGreen.icns")
    else()
#        set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/share/icons/${PROJECT_NAME}.png")
    endif()
#    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/v${CPACK_PACKAGE_VERSION}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_DESCRIPTION}")
endif()
set(CPACK_PACKAGE_CHECKSUM "SHA512")
#CPACK_RESOURCE_FILE_LICENSE
#CPACK_RESOURCE_FILE_README
#CPACK_RESOURCE_FILE_WELCOME
#set(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME};${PROJECT_DESCRIPTION}")
#CPACK_CREATE_DESKTOP_LINKS

set(CPACK_IFW_VERBOSE ON)
set(CPACK_IFW_PACKAGE_TITLE "${PROJECT_DESCRIPTION}")
set(CPACK_IFW_PRODUCT_URL "${CPACK_PACKAGE_HOMEPAGE_URL}")
set(CPACK_IFW_PACKAGE_PUBLISHER "${CPACK_PACKAGE_VENDOR}")
if(WIN32)
    #set(CPACK_IFW_PACKAGE_ICON ${CMAKE_SOURCE_DIR}/onLogoGreen.ico)
    set(CPACK_IFW_PACKAGE_WINDOW_ICON ${CMAKE_SOURCE_DIR}/onLogoGreen.png)
elseif(APPLE)
    set(CPACK_IFW_PACKAGE_ICON ${CMAKE_SOURCE_DIR}/onLogoGreen.icns)
endif()
set(CPACK_IFW_PACKAGE_LOGO "${CMAKE_SOURCE_DIR}/onLogoGreen-logo.png")
set(CPACK_IFW_PACKAGE_WATERMARK "${CMAKE_SOURCE_DIR}/onLogoGreen-watermark.png")
#CPACK_IFW_PACKAGE_BANNER
#CPACK_IFW_PACKAGE_BACKGROUND
set(CPACK_IFW_PACKAGE_WIZARD_STYLE "Modern")
set(CPACK_IFW_PACKAGE_WIZARD_DEFAULT_WIDTH 800)
set(CPACK_IFW_PACKAGE_WIZARD_DEFAULT_HEIGHT 480)
#CPACK_IFW_PACKAGE_TITLE_COLOR
if(WIN32)
    set(CPACK_IFW_PACKAGE_START_MENU_DIRECTORY "${CPACK_IFW_PACKAGE_NAME}")
endif()
set(CPACK_IFW_TARGET_DIRECTORY "@HomeDir@/${CPACK_PACKAGE_INSTALL_DIRECTORY}")
if (WIN32)
    set(CPACK_IFW_ADMIN_TARGET_DIRECTORY "@ApplicationsDirX64@/${CPACK_PACKAGE_INSTALL_DIRECTORY}")
#else ()
#    set(CPACK_IFW_ADMIN_TARGET_DIRECTORY "/opt/${CPACK_PACKAGE_INSTALL_DIRECTORY}")
endif ()
#CPACK_IFW_PACKAGE_GROUP
#CPACK_IFW_PACKAGE_NAME
#CPACK_IFW_PACKAGE_MAINTENANCE_TOOL_NAME i.e. 'maintenancetool.app'
#CPACK_IFW_PACKAGE_MAINTENANCE_TOOL_INI_FILE i.e. 'maintenancetool.ini
#CPACK_IFW_PACKAGE_REMOVE_TARGET_DIR
#CPACK_IFW_PACKAGE_CONTROL_SCRIPT ???
set(CPACK_IFW_DOWNLOAD_ALL ON)

include(CPack)

cpack_add_install_type(Runtime
    DISPLAY_NAME "Runtime"
)
cpack_add_install_type(All
    DISPLAY_NAME "All Components"
)

include(CPackIFW)

add_subdirectory(views)
add_subdirectory(sgwidgets)

add_subdirectory(plugins)

cpack_ifw_add_repository(main
    URL "http://127.0.0.1"
    DISPLAY_NAME "Spyglass cloud"
)





# app...
cpack_add_component_group(strata
    DISPLAY_NAME "Strata"
    DESCRIPTION "${PROJECT_DESCRIPTION}"
)
cpack_ifw_configure_component_group(strata
    NAME tech.spyglass.strata
)


# package
# ----------
# app group
cpack_add_component_group(app
    DISPLAY_NAME "${PROJECT_DESCRIPTION}"
    DESCRIPTION "TODO..."
    PARENT_GROUP strata
)
cpack_ifw_configure_component_group(app
    DEFAULT TRUE
    NAME tech.spyglass.strata.application
    VERSION ${PROJECT_VERSION}
    SORTING_PRIORITY 100
    DEPENDS tech.spyglass.strata.sgwidgets
    LICENSES Beerware ${CMAKE_SOURCE_DIR}/LICENSE_beerware.txt GPLv3 ${CMAKE_SOURCE_DIR}/LICENSE_gpl-3.0.txt
)
# app
cpack_add_component(application
    GROUP app
    INSTALL_TYPES All Runtime
)
cpack_ifw_configure_component(application
    NAME tech.spyglass.strata.application
    DEFAULT TRUE
)
