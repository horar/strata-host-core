option(TEST_PLATFORM_IDENTIFICATION "Build 'Platform Identification Test'" ON)
option(TEST_COMMUNICATION "Build 'Communication Test'" ON)

add_feature_info(TEST_PLATFORM_IDENTIFICATION TEST_PLATFORM_IDENTIFICATION "Platform Identification Test")
add_feature_info(TEST_COMMUNICATION TEST_COMMUNICATION "Communication Test")

if (TEST_PLATFORM_IDENTIFICATION)
   add_subdirectory(Platform-identification-test)
endif()

if (TEST_COMMUNICATION)
   add_subdirectory(communication)
endif()
