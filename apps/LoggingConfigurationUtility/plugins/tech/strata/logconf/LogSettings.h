/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QSettings>

class LogSettings : public QSettings
{
    Q_OBJECT
    Q_DISABLE_COPY(LogSettings)

public:
    LogSettings(QObject *parent = nullptr);
    Q_INVOKABLE QString filename();
    Q_INVOKABLE void removekey(const QString &key);

    Q_INVOKABLE QString getvalue(QString key);
    Q_INVOKABLE void setvalue(const QString &key, const QString &value);

signals:
    void paramValueChanged();
};
