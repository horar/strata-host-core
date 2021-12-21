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
    settings_(nullptr)
{
}

QString ConfigFileSettings::logLevel() const
{
    if (settings_->contains(LOG_LEVEL_SETTING) == false) {
        return "";
    }

    QStringList logLevels = {"debug", "info", "warning", "error", "critical", "off"};
    QString level = settings_->value(LOG_LEVEL_SETTING).toString();

    if (logLevels.contains(level)) {
        qCInfo(lcLcu) << "Current log level: " << level;
        return level;
    } else {
        qCWarning(lcLcu) << "Log level is '" << level << "', which is not a valid value. Setting log level to default.";
        return "debug"; //TBD if default should be info or debug
    }
}

QString ConfigFileSettings::filePath() const
{
    return settings_->fileName();
}

void ConfigFileSettings::setLogLevel(const QString& logLevel)
{
    if (logLevel == settings_->value(LOG_LEVEL_SETTING)) {
        return;
    }

    if (logLevel.isEmpty()) {
        settings_->remove(LOG_LEVEL_SETTING);
    } else {
        settings_->setValue(LOG_LEVEL_SETTING,logLevel);
    }

    emit logLevelChanged();
}

void ConfigFileSettings::setFilePath(const QString& filePath)
{
    if (settings_ != nullptr) {
        if (filePath == settings_->fileName()) {
            return;
        }
    }
    settings_.reset(new QSettings(filePath, QSettings::IniFormat));

    emit filePathChanged();
}
