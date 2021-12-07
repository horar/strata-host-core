/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QSettings>
#include <QFileInfo>

class ConfigFileSettings : public QSettings
{
    Q_OBJECT
    Q_PROPERTY(QString logLevel READ logLevel WRITE setLogLevel NOTIFY logLevelChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName)

public:
    explicit ConfigFileSettings(QObject *parent = 0);

    QString logLevel() const;
    QString fileName() const;
    void setLogLevel(QString logLevel);
    void setFileName(QString fileName);

signals:
    void logLevelChanged();

private:
    QFileInfo iniFile_;
};
