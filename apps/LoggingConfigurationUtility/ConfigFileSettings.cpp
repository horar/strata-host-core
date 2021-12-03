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
    iniFile_.setFile(this->fileName());
}

int ConfigFileSettings::logLevel() const
{
    QFile file(iniFile_.filePath());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return -1;
    QTextStream in(&file);
    QString line = in.readLine();
    while (!line.isNull()) {
        if(line.contains("level=")){
            QString level = line.split("=").at(1);
            if(level == "debug")
                return 0;
            else if (level == "info")
                return 1;
            else if (level == "warning")
                return 2;
            else if (level == "critical")
                return 3;
            else if (level == "error")
                return 4;
            else
                return 5;
        }
        line = in.readLine();
    }
    return -1;
}

void ConfigFileSettings::setLogLevel(int logLevel)
{
    QLoggingCategory category("strata.lcu");

    qCInfo(lcLcu) << "Set level: " << logLevel;

    switch (logLevel) {
    case 0:
        category.setEnabled(QtDebugMsg, true);
    case 1:
        category.setEnabled(QtInfoMsg, true);
    case 2:
        category.setEnabled(QtWarningMsg, true);
    case 3:
        category.setEnabled(QtCriticalMsg, true);
    case 4:
        category.setEnabled(QtFatalMsg, true);
    case 5: {
        category.setEnabled(QtDebugMsg, false);
        category.setEnabled(QtInfoMsg, false);
        category.setEnabled(QtWarningMsg, false);
        category.setEnabled(QtCriticalMsg, false);
        category.setEnabled(QtFatalMsg, false);
    }
    }

    //emit logLevelChanged();
}
