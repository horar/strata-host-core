/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <gtest/gtest.h>
#include <QString>
#include <QDir>
#include <QStandardPaths>

#include "SGUserSettings.h"

class SGUserSettingsTestEnvironment : public testing::Environment
{
public:
    void SetUp() override {
        settings = new SGUserSettings(nullptr, "SGUserSettings-test", "test");
    }

    void TearDown() override {
        QString settingsPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir dir(settingsPath);
        dir.cd("settings");

        if (dir.exists()) {
            dir.removeRecursively();
        }

        delete settings;
        settings = nullptr;
    }

    static SGUserSettings *settings;
};

class SGUserSettingsTest : public testing::Test
{
protected:
    void SetUp() override;

    virtual void TearDown() override;
};
