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
#include <QSettings>

ConfigFileSettings::ConfigFileSettings(QObject *parent) :
    QSettings(parent)
{
    iniFile_.setFile(this->fileName());
}

QFileInfo ConfigFileSettings::iniFile() const
{
    return iniFile_;
}

void ConfigFileSettings::updateFile(QFileInfo iniFile)
{
    emit fileUpdated();
}
