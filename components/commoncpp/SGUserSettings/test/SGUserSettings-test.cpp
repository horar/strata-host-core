/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGUserSettings-test.h"

#include <QString>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

SGUserSettings* SGUserSettingsTestEnvironment::settings = nullptr;

void SGUserSettingsTest::SetUp()
{
}

void SGUserSettingsTest::TearDown()
{
}


TEST_F(SGUserSettingsTest, testFileIO)
{
    QJsonObject json;
    QJsonArray arr;
    arr.append("test");
    arr.append("test2");
    json.insert("testValue", 0.5);
    json.insert("testArray", arr);

    EXPECT_TRUE(SGUserSettingsTestEnvironment::settings->writeFile("testSettings.json", json));
    EXPECT_EQ(SGUserSettingsTestEnvironment::settings->readFile("testSettings.json"), json);
    EXPECT_TRUE(SGUserSettingsTestEnvironment::settings->writeFile("testSettings.json", json, "test"));
    EXPECT_EQ(SGUserSettingsTestEnvironment::settings->readFile("testSettings.json", "test"), json);
}

TEST_F(SGUserSettingsTest, testRename)
{
    EXPECT_TRUE(SGUserSettingsTestEnvironment::settings->renameFile("testSettings.json", "testSettingsNew.json"));
    EXPECT_FALSE(SGUserSettingsTestEnvironment::settings->renameFile("nonExistent.json", "testSettings.json"));
    EXPECT_TRUE(SGUserSettingsTestEnvironment::settings->renameFile("testSettings.json", "testSettingsNew.json", "test"));
    EXPECT_TRUE(SGUserSettingsTestEnvironment::settings->renameFile("testSettingsNew.json", "testSettings.json"));
    EXPECT_TRUE(SGUserSettingsTestEnvironment::settings->renameFile("testSettingsNew.json", "testSettings.json", "test"));
}

TEST_F(SGUserSettingsTest, testDelete)
{
    EXPECT_TRUE(SGUserSettingsTestEnvironment::settings->deleteFile("testSettings.json", "test"));
    EXPECT_TRUE(SGUserSettingsTestEnvironment::settings->deleteFile("testSettings.json"));
    EXPECT_FALSE(SGUserSettingsTestEnvironment::settings->deleteFile("DoesNotExist.json"));
}
