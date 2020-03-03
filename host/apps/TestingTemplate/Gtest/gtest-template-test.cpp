#include "gtest-template-test.h"

void GtestTemplateTest::SetUp()
{
}

void GtestTemplateTest::TearDown()
{
}

TEST_F(GtestTemplateTest, testName1) {
    // test case
    templateLib myTemplateLib;
    EXPECT_TRUE(myTemplateLib.returnBool(true));
}

TEST_F(GtestTemplateTest, testName2) {
    // test case
    templateLib myTemplateLib;
    EXPECT_TRUE(myTemplateLib.returnBool(false));
}
