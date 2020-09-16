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
