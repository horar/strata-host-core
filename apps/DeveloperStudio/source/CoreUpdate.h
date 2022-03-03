/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QDir>

class CoreUpdate : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE QString requestUpdateApplication();

signals:
    void applicationTerminationRequested();

private:
    QString locateMaintenanceTool(const QDir &applicationDir, QString &absPathMaintenanceTool);

    void performCoreUpdate(const QString &absPathMaintenanceTool, const QDir &applicationDir);
};
