cmake_minimum_required(VERSION 3.13)

project(sds-setup
    VERSION 0.0.1
    DESCRIPTION "Strata Developer Studio"
    HOMEPAGE_URL "https://www.onsemi.com/"
    LANGUAGES NONE
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

# ---------------------------------------------------------------------------
# CPack stage
# ---------------------------------------------------------------------------
if(WIN32)
    set(CPACK_IFW_ROOT "c:/Dev/Qt/Tools/QtInstallerFramework/3.0")
elseif(APPLE)
    set(CPACK_IFW_ROOT "/Users/zbgvzx/dev/sdk/Qt/Tools/QtInstallerFramework/3.0")
else()
    message(FATAL_ERROR "TODO: ifw path...")
endif()

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
#set(CPACK_IFW_PACKAGE_WATERMARK "${CMAKE_SOURCE_DIR}/onLogoGreen-watermark.jpg")
set(CPACK_IFW_PACKAGE_WATERMARK "${CMAKE_SOURCE_DIR}/strataDS_logo.png")
#CPACK_IFW_PACKAGE_BANNER
#CPACK_IFW_PACKAGE_BACKGROUND
# Modern, Mac, Aero, Classic
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

#set(CPACK_IFW_REPOSITORIES_DIRECTORIES /Users/zbgvzx/repos)
#set(CPACK_IFW_PACKAGES_DIRECTORIES /Users/zbgvzx/repos)

include(CPack)

cpack_add_install_type(Runtime
    DISPLAY_NAME "Runtime"
)
cpack_add_install_type(All
    DISPLAY_NAME "All Components"
)

include(CPackIFW)

# projects/modules
add_subdirectory(strata)

#add_subdirectory(views)
#add_subdirectory(sgwidgets)

#add_subdirectory(plugins)

# default update package location
#if(CPACK_IFW_DOWNLOAD_ALL)
    cpack_ifw_add_repository(main
        URL "http://127.0.0.1"
        DISPLAY_NAME "Spyglass cloud"
    )
#endif()

