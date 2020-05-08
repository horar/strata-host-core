include(CMakeDependentOption)

option(APPS_TEST_TEMPLATE "Build 'Test Template'" OFF)
add_feature_info(APPS_TEST_TEMPLATE APPS_TEST_TEMPLATE "Test Template")

if (APPS_TEST_TEMPLATE)
   add_subdirectory(TestingTemplate)
endif()
