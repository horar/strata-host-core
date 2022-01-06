/*
 * Copyright (c) 2018-2022 onsemi.
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

int ConfigFileSettings::maxFileSize() const
{
    if (settings_->contains(LOG_MAXSIZE_SETTING) == false) {
        return 0;
    }

    int logMaxFileSize = settings_->value(LOG_MAXSIZE_SETTING).toInt();

    if (logMaxFileSize >= 1024 && logMaxFileSize <= 2147483647) {
        qCInfo(lcLcu) << "Current max size of log file : " << logMaxFileSize;
        return logMaxFileSize;
    } else {
        qCWarning(lcLcu) << "Max size of log file is '" << logMaxFileSize << "', which is not a valid value. Setting file size to default.";
        return 1024; //TBD
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

void ConfigFileSettings::setMaxFileSize(const int &maxFileSize)
{
    if (maxFileSize == settings_->value(LOG_MAXSIZE_SETTING)) {
        return;
    }

    if (maxFileSize == 0) {
        settings_->remove(LOG_MAXSIZE_SETTING);
    } else {
        settings_->setValue(LOG_MAXSIZE_SETTING, maxFileSize);
    }

    emit maxFileSizeChanged();
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
