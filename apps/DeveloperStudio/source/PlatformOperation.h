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
#include <QString>
#include <QJsonObject>

namespace strata::strataRPC {
    class StrataClient;
}

class PlatformOperation: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformOperation)

public:
    PlatformOperation(strata::strataRPC::StrataClient *strataClient, QObject *parent = nullptr);
    ~PlatformOperation();

    Q_INVOKABLE bool platformStartApplication(QString deviceId);

private slots:
    void replyHandler(QJsonObject payload);

private:
    strata::strataRPC::StrataClient *strataClient_;

};
