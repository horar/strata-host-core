/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGVersionUtils-test.h"

#include "SGVersionUtils.h"
#include <QString>

void SGVersionUtilsTest::SetUp()
{
}

void SGVersionUtilsTest::TearDown()
{
}

TEST_F(SGVersionUtilsTest, testCleanVersion)
{
    EXPECT_EQ("1.2.3", SGVersionUtils::cleanVersion("1.2.3.1-243-oaifjfioe-dirty"));
    EXPECT_EQ("1.2.3", SGVersionUtils::cleanVersion("v1.2.3"));
    EXPECT_EQ("1.2.3", SGVersionUtils::cleanVersion("v1.2.3.5.2.1.4"));
    EXPECT_EQ("", SGVersionUtils::cleanVersion("v1.2c.3"));
    EXPECT_EQ("", SGVersionUtils::cleanVersion("vv1.2.3"));
}

TEST_F(SGVersionUtilsTest, testValidVersion)
{
    EXPECT_TRUE(SGVersionUtils::valid("v1.2.3"));
    EXPECT_TRUE(SGVersionUtils::valid("1.2.3"));
    EXPECT_TRUE(SGVersionUtils::valid("v1.2.3.1-123-foiesjf"));
    EXPECT_TRUE(SGVersionUtils::valid("1.2"));
    EXPECT_TRUE(SGVersionUtils::valid("v1.2.3.2.3.4.4"));
    EXPECT_TRUE(SGVersionUtils::valid("1"));

    EXPECT_FALSE(SGVersionUtils::valid("v1.2v.3"));
    EXPECT_FALSE(SGVersionUtils::valid("v1.2."));
    EXPECT_FALSE(SGVersionUtils::valid("vv1.2.3"));
    EXPECT_FALSE(SGVersionUtils::valid("test"));
}

TEST_F(SGVersionUtilsTest, testCompareVersions)
{
    EXPECT_EQ(0, SGVersionUtils::compare("1.2", "1.2.0"));
    EXPECT_EQ(0, SGVersionUtils::compare("v1.2", "1.2.0"));
    EXPECT_EQ(0, SGVersionUtils::compare("v1.2.0.0", "v1.2.0"));
    EXPECT_EQ(-1, SGVersionUtils::compare("1.1.0", "1.2.0"));
    EXPECT_EQ(-1, SGVersionUtils::compare("v1.1.0", "v1.2.0"));
    EXPECT_EQ(-1, SGVersionUtils::compare("v1.1.0", "1.2.0.1-223-sfdsfd"));
    EXPECT_EQ(1, SGVersionUtils::compare("1.3.0", "1.2.0"));
    EXPECT_EQ(1, SGVersionUtils::compare("v1.3.0", "v1.2.0"));
    EXPECT_EQ(1, SGVersionUtils::compare("v1.3.0", "v1.2.0.1-1-123-fodsijf-dirty"));
    EXPECT_EQ(-2, SGVersionUtils::compare("vv1.3.0", "1.2.0"));
    EXPECT_EQ(-2, SGVersionUtils::compare("v1.3.0", "1.2d.0"));
}

TEST_F(SGVersionUtilsTest, testLtandGt)
{
    EXPECT_TRUE(SGVersionUtils::lessThan("1.2.0", "1.2.1"));
    EXPECT_FALSE(SGVersionUtils::lessThan("1.2.1", "1.2.1.2"));
    bool err = false;
    EXPECT_FALSE(SGVersionUtils::lessThan("1.v.3", "1.2.1", &err));
    EXPECT_TRUE(err);

    EXPECT_TRUE(SGVersionUtils::greaterThan("1.2.1", "1.2"));
    EXPECT_FALSE(SGVersionUtils::greaterThan("1.2", "1.2.0"));
    err = false;
    EXPECT_FALSE(SGVersionUtils::greaterThan("1.v.3", "1.2.1", &err));
    EXPECT_TRUE(err);
}

TEST_F(SGVersionUtilsTest, testGreatestVersion)
{
    QList<QString> goodVersions = {"1.2.0", "1.3.1", "v1.6.6", "v1.2.4.1-342-fdiosf", "v1.2.7"};
    QList<QString> badVersions = {"1.2.4", "1.5v.1", "v1.2.4.1-342-fdiosf", "v1.2.7", "v1.6.6"};
    bool err = false;

    EXPECT_EQ(2, SGVersionUtils::getGreatestVersion(goodVersions));
    EXPECT_EQ(-1, SGVersionUtils::getGreatestVersion(badVersions, &err));
    EXPECT_TRUE(err);
}
