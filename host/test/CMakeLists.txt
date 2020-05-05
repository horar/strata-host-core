option(TEST_PLATFORM_IDENTIFICATION "Build 'Platform Identification Test'" ON)
add_feature_info(TEST_PLATFORM_IDENTIFICATION TEST_PLATFORM_IDENTIFICATION "Platform Identification Test")

if (TEST_PLATFORM_IDENTIFICATION)
   add_subdirectory(Platform-identification-test)
endif()
