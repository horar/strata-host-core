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
    QObject(parent),
    settings_(new QSettings)
{
    iniFile_.setFile(settings_->fileName());
}

QString ConfigFileSettings::logLevel() const
{
    if (settings_->contains("log/level") == false) {
        return "";
    }

    QStringList logLevels = {"debug", "info", "warning", "error", "critical", "off"};
    QString level = settings_->value("log/level", QVariant()).toString();

    if (logLevels.contains(level)) {
        qCInfo(lcLcu) << "Current log level: " << level;
        return level;
    } else {
        qCWarning(lcLcu) << "Unrecognized log level. Setting to default." << level;
        return "debug"; //TBD if default should be info or debug
    }
}

QString ConfigFileSettings::fileName() const
{
    return iniFile_.fileName();
}

void ConfigFileSettings::setLogLevel(const QString& logLevel)
{
    if (logLevel == settings_->value("log/lovel")) {
        return;
    }

    if (logLevel.isEmpty()) {
        settings_->remove("log/level");
    } else {
        settings_->setValue("log/level",logLevel);
    }

    emit logLevelChanged();
}

void ConfigFileSettings::setFileName(const QString& fileName)
{
    if (fileName == iniFile_.fileName()) {
        return;
    }

    iniFile_.setFile(iniFile_.absolutePath() + "/" + fileName);
    settings_.reset(new QSettings(iniFile_.filePath(), QSettings::IniFormat));

    emit fileNameChanged();
}
