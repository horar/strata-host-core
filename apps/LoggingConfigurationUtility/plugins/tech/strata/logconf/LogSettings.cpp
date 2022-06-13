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
#include "logging/LoggingQtCategories.h"

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

bool LogSettings::checkValue(QString key)
{
    QString value = this->value(key).toString();

    if (key == "level") {
        QStringList logLevels = {"debug", "info", "warning", "error", "critical", "off"};

        if (logLevels.contains(value) == false) {
            qCWarning(lcLcu) << "Parameter" << key << "is set to" << value << ", which is not a valid value.";
            return false;
        }
        return true;

    } else if (key == "maxFileSize") {
           bool ok = false;
           int logMaxFileSize = value.toInt(&ok);

           if (ok) {
               if (logMaxFileSize >= 2147483647 || logMaxFileSize <= 1000) {
                   qCWarning(lcLcu) << "Max file size out of range :" << value;
                   return false;
               } else {
                   return true;
               }
           } else {
               qCWarning(lcLcu) << "Parameter" << key << "is set to" << value << ", which is not a valid value.";
               return false;
           }

    } else if (key == "maxNoFiles") {
        bool ok = false;
        int logMaxNoFiles = value.toInt(&ok);

        if (ok) {
            if (logMaxNoFiles >= 100000 || logMaxNoFiles <= 1) {
                qCWarning(lcLcu) << "Max number of files out of range :" << value;
                return false;
            } else {
                return true;
            }
        } else {
            qCWarning(lcLcu) << "Parameter" << key << "is set to" << value << ", which is not a valid value.";
            return false;
        }

    } else {
        if (value.isEmpty() == true) {
            qCWarning(lcLcu) << "Parameter" << key << "is set to" << value << ", which is not a valid value.";
            return false;
        }
        return true;
    }
}

QString LogSettings::filename()
{
    return this->fileName();
}

QString LogSettings::getvalue(QString key)
{
    if (this->contains(key) == false) {
        return "";
    }

    QString value = this->value(key).toString();

    if (checkValue(key)) {
        return value;
    } else {
        emit corruptedFile(key, value);
    }

    return "";
}

void LogSettings::removekey(const QString &key)
{
    this->remove(key);
}

void LogSettings::setvalue(const QString &key, const QString &value)
{
    this->setValue(key,value);
}
