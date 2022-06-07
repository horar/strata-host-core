/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LogSettings.h"
#include <QtLoggerDefaults.h>

LogSettings::LogSettings(QObject *parent)
    : QSettings(parent)
{
    this->beginGroup("log");
}

int LogSettings::maxSizeDefault() const
{
    return strata::loggers::defaults::LOGFILE_MAX_SIZE;
}

int LogSettings::maxCountDefault() const
{
    return strata::loggers::defaults::LOGFILE_MAX_COUNT;
}

QString LogSettings::filterRulesDefault() const
{
    return strata::loggers::defaults::QT_FILTER_RULES;
}

QString LogSettings::qtMsgDefault() const
{
    return strata::loggers::defaults::QT_MESSAGE_PATTERN;
}

QString LogSettings::spdMsgDefault() const
{
    return strata::loggers::defaults::SPDLOG_MESSAGE_PATTERN_4CONSOLE;
}

QString LogSettings::filename()
{
    return this->fileName();
}

QString LogSettings::getvalue(QString key)
{
    return this->value(key).toString();
}

void LogSettings::removekey(const QString &key)
{
    this->remove(key);
}

void LogSettings::setvalue(const QString &key, const QString &value)
{
    this->setValue(key,value);
}
