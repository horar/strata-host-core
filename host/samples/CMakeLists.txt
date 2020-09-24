option(TEST_TEMPLATE "Build 'Test Template'" OFF)
add_feature_info(TEST_TEMPLATE TEST_TEMPLATE "Test Template")

if (TEST_TEMPLATE)
   add_subdirectory(TestingTemplate)
endif()
