if(APPS_UTILS)
    # TODO (LC): why here??
    add_subdirectory(hcc_test)
    # temporarily disabled
    #add_subdirectory(platform_mgr_test)
endif()

cmake_dependent_option(APPS_UTILS_RCC "Build 'RCC files utility'" ON
    "APPS_UTILS" OFF)
add_feature_info(APPS_UTILS_RCC APPS_UTILS_RCC "RCC files utility")

if (APPS_UTILS_RCC)
    add_subdirectory(rcc-util)
endif()
