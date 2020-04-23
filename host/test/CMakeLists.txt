include(CMakeDependentOption)

option(PLATFORM_IDENTIFICATION_TEST "Build 'Platform Identification Test'" ON)
add_feature_info(PLATFORM_IDENTIFICATION_TEST PLATFORM_IDENTIFICATION_TEST "Platform Identification Test")

if (PLATFORM_IDENTIFICATION_TEST)
   add_subdirectory(Platform-identification-test)
endif()
