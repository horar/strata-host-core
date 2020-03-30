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

// the "DISABLED_" is to skip the test case.
TEST_F(GtestTemplateTest, DISABLED_testName2) {
    // test case
    templateLib myTemplateLib;
    EXPECT_TRUE(myTemplateLib.returnBool(false));
}

TEST_F(GtestTemplateTest, signalTest) {
    // signal set-up
    templateLib template_1, template_2;
    QObject::connect(&template_1, &templateLib::valueChanged, &template_2, &templateLib::setValue);
    int newValue = 0;

    // invoke the signal
    template_1.setValue(newValue);
    // check values
    EXPECT_EQ(template_1.getValue(), newValue);
    EXPECT_EQ(template_2.getValue(), template_1.getValue());

    newValue = 2;
    template_1.setValue(newValue);
    EXPECT_EQ(template_1.getValue(), newValue);
    EXPECT_EQ(template_2.getValue(), template_1.getValue());

    newValue = 2;
    template_1.setValue(newValue);
    EXPECT_EQ(template_1.getValue(), newValue);
    EXPECT_EQ(template_2.getValue(), template_1.getValue());

    newValue = 54;
    template_1.setValue(newValue);
    EXPECT_EQ(template_1.getValue(), newValue);
    EXPECT_EQ(template_2.getValue(), template_1.getValue());

    newValue = 34;
    template_1.setValue(newValue);
    EXPECT_EQ(template_1.getValue(), newValue);
    EXPECT_EQ(template_2.getValue(), template_1.getValue());

    newValue = 6;
    template_1.setValue(newValue);
    EXPECT_EQ(template_1.getValue(), newValue);
    EXPECT_EQ(template_2.getValue(), template_1.getValue());
}

TEST_F(GtestTemplateTest, signalTestWithQtestTools) {
    // signal set-up
    templateLib template_1, template_2;
    QObject::connect(&template_1, &templateLib::valueChanged, &template_2, &templateLib::setValue);
    
    // set-up QSignalSpy -> a list of the emittied singals.
    // record valueChanged signal from template_1
    QSignalSpy mSpy(&template_1, &templateLib::valueChanged);

    // invoke the signal
    template_1.setValue(1);
    template_1.setValue(1); // Signal won't be emmited
    template_1.setValue(13);
    template_1.setValue(2);
    template_1.setValue(10);
    template_1.setValue(5);

    // check values
    EXPECT_EQ(template_1.getValue(), 5);
    EXPECT_EQ(template_2.getValue(), template_1.getValue());

    // check how many singals were emitted
    EXPECT_EQ(mSpy.count(), 5);

    // Inspect emitted signals
    EXPECT_EQ(mSpy.at(0).at(0).toInt(), 1);
    EXPECT_EQ(mSpy.at(1).at(0).toInt(), 13);
    EXPECT_EQ(mSpy.at(2).at(0).toInt(), 2);
    EXPECT_EQ(mSpy.at(3).at(0).toInt(), 10);
    EXPECT_EQ(mSpy.at(4).at(0).toInt(), 5);
}
