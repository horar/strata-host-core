/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ConfigFileSettings.h"
#include "logging/LoggingQtCategories.h"

#include <QFileInfo>
#include <QFile>
#include <QSettings>

ConfigFileSettings::ConfigFileSettings(QObject *parent) :
    QSettings(parent)
{
    QSettings settings;
    iniFile_.setFile(settings.fileName());
}

QString ConfigFileSettings::logLevel() const
{
    QSettings settings(iniFile_.filePath(), QSettings::IniFormat);

    QStringList keys = settings.allKeys();
    if (!keys.contains("log/level")) {
        return "";
    }

    QString level = settings.value("log/level",QVariant()).toString();
    qCInfo(lcLcu) << "log level: " << level;

    return level;
}

QString ConfigFileSettings::fileName() const
{
    return iniFile_.fileName();
}

void ConfigFileSettings::setLogLevel(QString logLevel)
{
    QSettings settings(iniFile_.filePath(), QSettings::IniFormat);

    if (logLevel == "") {
        settings.remove("log/level");
    } else {
        settings.setValue("log/level",logLevel);
    }
}

void ConfigFileSettings::setFileName(QString fileName)
{
    iniFile_.setFile(iniFile_.absolutePath() + "/" + fileName);
}
