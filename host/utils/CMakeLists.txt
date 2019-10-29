add_subdirectory(serial_test)
add_subdirectory(hcc_test)
add_subdirectory(platform_mgr_test)

option(UTILS_RCC "Build 'RCC files utility'" ON)
add_feature_info(UTILS_RCC UTILS_RCC "RCC files utility")

if (UTILS_RCC)
    add_subdirectory(rcc-util)
endif()
