/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LogSettings.h"

LogSettings::LogSettings(QObject *parent)
    : QSettings(parent)
{
    this->beginGroup("log");
}

QString LogSettings::filename()
{
    return this->fileName();

}

void LogSettings::removekey(const QString &key)
{
    this->remove(key);
}

QString LogSettings::getvalue(QString key)
{
    return this->value(key).toString();
}

void LogSettings::setvalue(const QString &key, const QString &value)
{
    this->setValue(key,value);
}
