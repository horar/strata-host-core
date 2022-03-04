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
#include <QtLoggerDefaults.h>

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
        qCDebug(lcLcu) << "Current log level: " << level;
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

    if (logMaxFileSize >= MIN_LOGFILE_SIZE && logMaxFileSize <= MAX_LOGFILE_SIZE) {
        qCDebug(lcLcu) << "Current max size of log file : " << logMaxFileSize;
        return logMaxFileSize;
    } else {
        qCWarning(lcLcu) << "Max size of log file is '" << logMaxFileSize << "', which is not a valid value. Setting file size to default.";
        return maxSizeDefault();
    }
}

int ConfigFileSettings::maxNoFiles() const
{
    if (settings_->contains(LOG_MAXNOFILES_SETTING) == false) {
        return 0;
    }

    int logMaxNoFiles = settings_->value(LOG_MAXNOFILES_SETTING).toInt();

    if (logMaxNoFiles >= MIN_NOFILES && logMaxNoFiles <= MAX_NOFILES) {
        qCDebug(lcLcu) << "Current max size of log file : " << logMaxNoFiles;
        return logMaxNoFiles;
    } else {
        qCWarning(lcLcu) << "Max number of log files is '" << logMaxNoFiles << "', which is not a valid value. Setting number of files to default.";
        return maxCountDefault();
    }
}

QString ConfigFileSettings::qtFilterRules() const
{
    if (settings_->contains(LOG_FILTERRULES_SETTING) == false) {
        return 0;
    }

    QString qtFilterRules = settings_->value(LOG_FILTERRULES_SETTING).toString();

    if (qtFilterRules.isEmpty() == false) {
        qCDebug(lcLcu) << "Current Qt filter rules : " << qtFilterRules;
        return qtFilterRules;
    } else {
        qCWarning(lcLcu) << "Qt filter rules are '" << qtFilterRules << "', which is not a valid value. Setting Qt filter rules to default.";
        return filterRulesDefault(); //TBD
    }
}

QString ConfigFileSettings::qtMsgPattern() const
{
    if (settings_->contains(LOG_QT_MSGPATTERN_SETTING) == false) {
        return 0;
    }

    QString qtMsgPattern = settings_->value(LOG_QT_MSGPATTERN_SETTING).toString();

    if (qtMsgPattern.isEmpty() == false) {
        qCDebug(lcLcu) << "Current Qt message pattern : " << qtMsgPattern;
        return qtMsgPattern;
    } else {
        qCWarning(lcLcu) << "Qt message pattern is '" << qtMsgPattern << "', which is not a valid value. Setting Qt message pattern to default.";
        return qtMsgDefault();
    }
}

QString ConfigFileSettings::spdlogMsgPattern() const
{
    if (settings_->contains(LOG_SPD_MSGPATTERN_SETTING) == false) {
        return 0;
    }

    QString spdMsgPattern = settings_->value(LOG_SPD_MSGPATTERN_SETTING).toString();

    if (spdMsgPattern.isEmpty() == false) {
        qCDebug(lcLcu) << "Current spdlog message pattern : " << spdMsgPattern;
        return spdMsgPattern;
    } else {
        qCWarning(lcLcu) << "spdlog message pattern is '" << spdMsgPattern << "', which is not a valid value. Setting spdlog message pattern to default.";
        return spdMsgDefault();
    }
}

QString ConfigFileSettings::filePath() const
{
    return settings_->fileName();
}

int ConfigFileSettings::maxSizeDefault() const
{
    return strata::loggers::defaults::LOGFILE_MAX_SIZE;
}

int ConfigFileSettings::maxCountDefault() const
{
    return strata::loggers::defaults::LOGFILE_MAX_COUNT;
}

QString ConfigFileSettings::filterRulesDefault() const
{
    return strata::loggers::defaults::QT_FILTER_RULES;
}

QString ConfigFileSettings::qtMsgDefault() const
{
    return strata::loggers::defaults::QT_MESSAGE_PATTERN;
}

QString ConfigFileSettings::spdMsgDefault() const
{
    return strata::loggers::defaults::SPDLOG_MESSAGE_PATTERN_4CONSOLE;
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
        if (maxFileSize == MAX_LOGFILE_SIZE || maxFileSize == MIN_LOGFILE_SIZE) {
            emit maxFileSizeChanged();
        }
        return;
    }

    if (maxFileSize == 0) {
        settings_->remove(LOG_MAXSIZE_SETTING);
    } else {
        settings_->setValue(LOG_MAXSIZE_SETTING, maxFileSize);
    }

    emit maxFileSizeChanged();
}

void ConfigFileSettings::setMaxNoFiles(const int &maxNoFiles)
{
    if (maxNoFiles == settings_->value(LOG_MAXNOFILES_SETTING)) {
        if (maxNoFiles == MAX_NOFILES || maxNoFiles == MIN_NOFILES) {
            emit maxNoFilesChanged();
        }
        return;
    }

    if (maxNoFiles == 0) {
        settings_->remove(LOG_MAXNOFILES_SETTING);
    } else {
        settings_->setValue(LOG_MAXNOFILES_SETTING, maxNoFiles);
    }

    emit maxNoFilesChanged();
}

void ConfigFileSettings::setQtFilterRules(const QString &qtFilterRules)
{
    if (qtFilterRules == settings_->value(LOG_FILTERRULES_SETTING)) {
        return;
    }

    if (qtFilterRules.isEmpty()) {
        settings_->remove(LOG_FILTERRULES_SETTING);
    } else {
        settings_->setValue(LOG_FILTERRULES_SETTING, qtFilterRules);
    }

    emit qtFilterRulesChanged();
}

void ConfigFileSettings::setQtMsgPattern(const QString &qtMessagePattern)
{
    if (qtMessagePattern == settings_->value(LOG_QT_MSGPATTERN_SETTING)) {
        return;
    }

    if (qtMessagePattern.isEmpty()) {
        settings_->remove(LOG_QT_MSGPATTERN_SETTING);
    } else {
        settings_->setValue(LOG_QT_MSGPATTERN_SETTING, qtMessagePattern);
    }

    emit qtMsgPatternChanged();
}

void ConfigFileSettings::setSpdlogMsgPattern(const QString &spdlogMessagePattern)
{
    if (spdlogMessagePattern == settings_->value(LOG_QT_MSGPATTERN_SETTING)) {
        return;
    }

    if (spdlogMessagePattern.isEmpty()) {
        settings_->remove(LOG_SPD_MSGPATTERN_SETTING);
    } else {
        settings_->setValue(LOG_SPD_MSGPATTERN_SETTING, spdlogMessagePattern);
    }

    emit spdlogMsgPatternChanged();
}

void ConfigFileSettings::setFilePath(const QString& filePath)
{
    if (settings_ != nullptr && filePath == settings_->fileName()) {
        return;
    }
    settings_.reset(new QSettings(filePath, QSettings::IniFormat));

    emit filePathChanged();
}
